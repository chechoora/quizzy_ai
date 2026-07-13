import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

/// An editable card held locally by the cubit. [localId] is a stable key used
/// by the UI to seed per-card text controllers without resetting them.
class EditCard extends Equatable {
  const EditCard({
    required this.localId,
    required this.question,
    required this.answer,
  });

  final int localId;
  final String question;
  final String answer;

  EditCard copyWith({String? question, String? answer}) {
    return EditCard(
      localId: localId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  PlainCardModel toPlain() =>
      PlainCardModel(question: question, answer: answer);

  @override
  List<Object?> get props => [localId, question, answer];
}

class DeckEditCubit extends Cubit<AiGenerateState> {
  DeckEditCubit({
    required this.aiGenService,
    required this.deckItem,
    required this.quizCardRepository,
    required this.inAppPurchaseService,
  }) : super(const AiGenerateInitialState());

  final AiGenService aiGenService;
  final DeckItem deckItem;
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;

  final _logger = Logger.withTag('AiGenerateCubit');

  final List<EditCard> _cards = [];

  /// The deck's existing cards, kept so [save] can clear the deck before
  /// writing the edited set back.
  final List<QuizCardItem> _existingCards = [];
  int _localIdCounter = 0;

  /// Whether the user owns the AI (`quizzyAi`) entitlement. Free users can edit
  /// cards but the AI composer is replaced by an unlock CTA.
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool get hasContent => _cards.isNotEmpty;

  /// Resolves the AI entitlement and loads the deck's existing (non-archived)
  /// cards so they are shown as editable tiles and included as context for
  /// refinement.
  Future<void> init() async {
    try {
      _isPremium = await inAppPurchaseService
          .isFeaturePurchased(InAppPurchaseFeature.quizzyAi);
      final items = await quizCardRepository.fetchQuizCardItem(deckItem.id);
      final active = items.where((i) => !i.isArchive).toList();
      _existingCards
        ..clear()
        ..addAll(active);
      _cards
        ..clear()
        ..addAll(active.map(_fromExisting));
      _emitContent();
    } catch (e, s) {
      _logger.e('load existing cards failed', ex: e, stacktrace: s);
    }
  }

  /// Switches the screen to premium mode in place after a successful purchase.
  void onAiUnlocked() {
    _isPremium = true;
    _emitContent();
  }

  /// First generation from a prompt. The deck's existing title is passed to the
  /// service as generation context.
  Future<void> generate(String prompt) async {
    if (prompt.trim().isEmpty) return;
    emit(AiGenerateGeneratingState(
      cards: List.from(_cards),
      isPremium: _isPremium,
    ));
    try {
      final deck = await aiGenService.generate(
        AiGenRequest(prompt: prompt, deckTitle: deckItem.title),
      );
      _cards
        ..clear()
        ..addAll(deck.cards.map(_toEditable));
      _emitContent();
    } catch (e, s) {
      _logger.e('generate failed', ex: e, stacktrace: s);
      emit(AiGenerateErrorState('Failed to generate cards. Please try again.'));
      _emitContent();
    }
  }

  /// Follow-up prompt that refines the currently generated cards in place.
  Future<void> refine(String prompt) async {
    if (prompt.trim().isEmpty) return;
    emit(AiGenerateGeneratingState(
      cards: List.from(_cards),
      isPremium: _isPremium,
    ));
    try {
      final deck = await aiGenService.generate(
        AiGenRequest(
          prompt: prompt,
          deckTitle: deckItem.title,
          currentCards: _cards.map((c) => c.toPlain()).toList(),
        ),
      );
      _cards
        ..clear()
        ..addAll(deck.cards.map(_toEditable));
      _emitContent();
    } catch (e, s) {
      _logger.e('refine failed', ex: e, stacktrace: s);
      emit(AiGenerateErrorState('Failed to refine cards. Please try again.'));
      _emitContent();
    }
  }

  /// Silent update — does not emit, to avoid resetting inline text controllers.
  void updateCard(int localId, {String? question, String? answer}) {
    final index = _cards.indexWhere((c) => c.localId == localId);
    if (index == -1) return;
    _cards[index] =
        _cards[index].copyWith(question: question, answer: answer);
  }

  void addCard() {
    _cards.add(
      EditCard(localId: _nextId(), question: '', answer: ''),
    );
    _emitContent();
  }

  void deleteCard(int localId) {
    _cards.removeWhere((c) => c.localId == localId);
    _emitContent();
  }

  /// Resets the deck: removes all existing cards, then writes the current
  /// edited set. Simpler than diffing and safe because this screen is
  /// pro-only, so no premium gating is needed here.
  Future<void> save() async {
    final cards = _cards
        .where((c) => c.question.trim().isNotEmpty || c.answer.trim().isNotEmpty)
        .map((c) => c.toPlain())
        .toList();
    if (cards.isEmpty) {
      emit(AiGenerateErrorState('Add at least one card before saving.'));
      _emitContent();
      return;
    }

    try {
      for (final existing in _existingCards) {
        await quizCardRepository.deleteQuizCard(existing);
      }
      _existingCards.clear();
      await quizCardRepository.saveQuizCards(cards, deckItem.id);
      emit(AiGenerateSavedState());
    } catch (e, s) {
      _logger.e('save failed', ex: e, stacktrace: s);
      emit(AiGenerateErrorState('Failed to save cards. Please try again.'));
      _emitContent();
    }
  }

  EditCard _fromExisting(QuizCardItem item) => EditCard(
        localId: _nextId(),
        question: item.questionText,
        answer: item.answerText,
      );

  EditCard _toEditable(PlainCardModel model) => EditCard(
        localId: _nextId(),
        question: model.question,
        answer: model.answer,
      );

  int _nextId() => _localIdCounter++;

  void _emitContent() {
    emit(
      AiGenerateContentState(
        title: deckItem.title,
        cards: List.from(_cards),
        isPremium: _isPremium,
      ),
    );
  }
}

abstract class AiGenerateState extends Equatable {
  const AiGenerateState();
}

abstract class BuilderState extends AiGenerateState {
  const BuilderState();
}

abstract class ListenerState extends AiGenerateState with UniqueEmit {
  ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class AiGenerateInitialState extends BuilderState {
  const AiGenerateInitialState();

  @override
  List<Object?> get props => [];
}

class AiGenerateGeneratingState extends BuilderState {
  const AiGenerateGeneratingState({
    this.cards = const [],
    this.isPremium = false,
  });

  final List<EditCard> cards;
  final bool isPremium;

  @override
  List<Object?> get props => [cards, isPremium];
}

class AiGenerateContentState extends BuilderState {
  const AiGenerateContentState({
    required this.title,
    required this.cards,
    required this.isPremium,
  });

  final String title;
  final List<EditCard> cards;
  final bool isPremium;

  @override
  List<Object?> get props => [title, cards, isPremium];
}

class AiGenerateSavedState extends ListenerState {
  AiGenerateSavedState();
}

class AiGenerateErrorState extends ListenerState {
  AiGenerateErrorState(this.message);

  final String message;
}
