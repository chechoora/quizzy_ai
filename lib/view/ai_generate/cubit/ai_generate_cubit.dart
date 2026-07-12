import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

/// An editable card held locally by the cubit. [localId] is a stable key used
/// by the UI to seed per-card text controllers without resetting them.
class AiGenerateCard extends Equatable {
  const AiGenerateCard({
    required this.localId,
    required this.question,
    required this.answer,
  });

  final int localId;
  final String question;
  final String answer;

  AiGenerateCard copyWith({String? question, String? answer}) {
    return AiGenerateCard(
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

class AiGenerateCubit extends Cubit<AiGenerateState> {
  AiGenerateCubit({
    required this.aiGenService,
    required this.deckRepository,
    required this.quizCardRepository,
    required this.deckPremiumManager,
  }) : super(const AiGenerateInitialState());

  final AiGenService aiGenService;
  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final DeckPremiumManager deckPremiumManager;

  final _logger = Logger.withTag('AiGenerateCubit');

  String _deckTitle = '';
  final List<AiGenerateCard> _cards = [];
  int _localIdCounter = 0;

  bool get hasContent => _cards.isNotEmpty;

  /// First generation from a prompt. [title] is the optional user-typed title.
  Future<void> generate(String prompt, {String? title}) async {
    if (prompt.trim().isEmpty) return;
    emit(AiGenerateGeneratingState(cards: List.from(_cards)));
    try {
      final deck = await aiGenService.generate(
        AiGenRequest(prompt: prompt, deckTitle: title),
      );
      _deckTitle = deck.title;
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
    emit(AiGenerateGeneratingState(cards: List.from(_cards)));
    try {
      final deck = await aiGenService.generate(
        AiGenRequest(
          prompt: prompt,
          deckTitle: _deckTitle,
          currentCards: _cards.map((c) => c.toPlain()).toList(),
        ),
      );
      if (_deckTitle.trim().isEmpty) {
        _deckTitle = deck.title;
      }
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
  void setTitle(String title) {
    _deckTitle = title;
  }

  /// Silent update — see [setTitle].
  void updateCard(int localId, {String? question, String? answer}) {
    final index = _cards.indexWhere((c) => c.localId == localId);
    if (index == -1) return;
    _cards[index] =
        _cards[index].copyWith(question: question, answer: answer);
  }

  void addCard() {
    _cards.add(
      AiGenerateCard(localId: _nextId(), question: '', answer: ''),
    );
    _emitContent();
  }

  void deleteCard(int localId) {
    _cards.removeWhere((c) => c.localId == localId);
    _emitContent();
  }

  Future<void> save() async {
    final title = _deckTitle.trim().isEmpty ? 'New AI Deck' : _deckTitle.trim();
    final cards = _cards
        .where((c) => c.question.trim().isNotEmpty || c.answer.trim().isNotEmpty)
        .map((c) => c.toPlain())
        .toList();
    if (cards.isEmpty) {
      emit(AiGenerateErrorState('Add at least one card before saving.'));
      _emitContent();
      return;
    }

    final canAddDeck = await deckPremiumManager.canAddDeck();
    if (!canAddDeck) {
      emit(AiGenerateSaveBlockedState());
      _emitContent();
      return;
    }

    try {
      final deckId = await deckRepository.saveDeck(title);
      await quizCardRepository.saveQuizCards(cards, deckId);
      emit(AiGenerateSavedState());
    } catch (e, s) {
      _logger.e('save failed', ex: e, stacktrace: s);
      emit(AiGenerateErrorState('Failed to save deck. Please try again.'));
      _emitContent();
    }
  }

  AiGenerateCard _toEditable(PlainCardModel model) => AiGenerateCard(
        localId: _nextId(),
        question: model.question,
        answer: model.answer,
      );

  int _nextId() => _localIdCounter++;

  void _emitContent() {
    emit(
      AiGenerateContentState(
        title: _deckTitle,
        cards: List.from(_cards),
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
  const AiGenerateGeneratingState({this.cards = const []});

  final List<AiGenerateCard> cards;

  @override
  List<Object?> get props => [cards];
}

class AiGenerateContentState extends BuilderState {
  const AiGenerateContentState({
    required this.title,
    required this.cards,
  });

  final String title;
  final List<AiGenerateCard> cards;

  @override
  List<Object?> get props => [title, cards];
}

class AiGenerateSavedState extends ListenerState {
  AiGenerateSavedState();
}

class AiGenerateSaveBlockedState extends ListenerState {
  AiGenerateSaveBlockedState();
}

class AiGenerateErrorState extends ListenerState {
  AiGenerateErrorState(this.message);

  final String message;
}
