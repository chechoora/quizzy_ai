import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_events.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_exe_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class QuizCardListCubit extends Cubit<QuizCardListState> {
  QuizCardListCubit({
    required this.deckItem,
    required this.quizCardRepository,
    required this.deckRepository,
    required this.quizCardPremiumManager,
    required this.quizCardExeValidator,
    required this.analyticsService,
    required this.isSubscriptionOnly,
  }) : super(QuizCardListLoadingState());

  final DeckItem deckItem;
  final QuizCardRepository quizCardRepository;
  final DeckRepository deckRepository;
  final QuizCardPremiumManager quizCardPremiumManager;
  final QuizCardExeValidator quizCardExeValidator;
  final AnalyticsService analyticsService;

  /// When true (the `quizzypro` flavor) only the Quizzy AI subscription is
  /// offered; when false (the `quizzy` flavor) only the one-time "unlimited
  /// decks/cards" purchase is offered.
  final bool isSubscriptionOnly;

  final items = <QuizCardItem>[];
  final _selectedCardIds = <int>{};
  StreamSubscription<List<QuizCardItem>>? _cardsSubscription;
  StreamSubscription<DeckItem?>? _deckSubscription;

  /// Latest deck stats seen from [watchDeck]. Falls back to the stats the
  /// screen was opened with until the deck's own watch stream emits.
  ItemStats? _deckStatsOverride;
  ItemStats? get _deckStats => _deckStatsOverride ?? deckItem.stats;

  /// The purchase feature to offer when the card limit is hit, resolved from
  /// the active flavor: `quizzyAi` subscription on `quizzypro`, the one-time
  /// `unlimitedDecksCards` purchase on `quizzy`.
  InAppPurchaseFeature get unlockFeature => isSubscriptionOnly
      ? InAppPurchaseFeature.quizzyAi
      : InAppPurchaseFeature.unlimitedDecksCards;

  void toggleCardSelection(int cardId) {
    if (_selectedCardIds.contains(cardId)) {
      _selectedCardIds.remove(cardId);
    } else {
      _selectedCardIds.add(cardId);
    }
    emit(
      QuizCardListDataState(
        quizCarList: List.from(items),
        selectedCardIds: Set.from(_selectedCardIds),
        deckStats: _deckStats,
      ),
    );
  }

  void selectAllCards() {
    _selectedCardIds
      ..clear()
      ..addAll(items.map((card) => card.id));
    emit(
      QuizCardListDataState(
        quizCarList: List.from(items),
        selectedCardIds: Set.from(_selectedCardIds),
        deckStats: _deckStats,
      ),
    );
  }

  void clearSelection() {
    _selectedCardIds.clear();
    emit(
      QuizCardListDataState(
        quizCarList: List.from(items),
        selectedCardIds: const {},
        deckStats: _deckStats,
      ),
    );
  }

  void watchCards() {
    _cardsSubscription?.cancel();
    _cardsSubscription =
        quizCardRepository.watchQuizCardList(deckItem.id).listen(
      (data) {
        items
          ..clear()
          ..addAll(data);
        final validIds = data.map((card) => card.id).toSet();
        _selectedCardIds.retainWhere(validIds.contains);
        emit(
          QuizCardListDataState(
            quizCarList: List.from(items),
            selectedCardIds: Set.from(_selectedCardIds),
            deckStats: _deckStats,
          ),
        );
      },
    );
  }

  /// Watches this deck's own stats so they stay live (e.g. right after sync
  /// pushes updated play stats). Only re-emits once the cards have loaded at
  /// least once, since [watchCards] and [watchDeck] fire independently and
  /// deck data may arrive first.
  void watchDeck() {
    _deckSubscription?.cancel();
    _deckSubscription = deckRepository.watchDeck(deckItem.id).listen(
      (data) {
        _deckStatsOverride = data?.stats;
        if (state is QuizCardListDataState) {
          emit(
            QuizCardListDataState(
              quizCarList: List.from(items),
              selectedCardIds: Set.from(_selectedCardIds),
              deckStats: _deckStats,
            ),
          );
        }
      },
    );
  }

  void createQuizCardItem(QuizCardRequestItem requestItem) {
    quizCardRepository.saveQuizCard(
      question: requestItem.question,
      answer: requestItem.answer,
      deckId: deckItem.id,
    );
  }

  void deleteCard(QuizCardItem card) {
    quizCardRepository.deleteQuizCard(card);
  }

  void editQuizCard(
      QuizCardItem card, QuizCardRequestItem quizCardRequestItem) {
    quizCardRepository.editQuizCard(
      currentCard: card,
      request: quizCardRequestItem,
    );
    unawaited(analyticsService.track(AnalyticsEvents.cardEdited, properties: {
      AnalyticsProperties.deckId: deckItem.id,
      AnalyticsProperties.field: 'question',
      AnalyticsProperties.wasEdited: card.questionText != quizCardRequestItem.question,
    }));
    unawaited(analyticsService.track(AnalyticsEvents.cardEdited, properties: {
      AnalyticsProperties.deckId: deckItem.id,
      AnalyticsProperties.field: 'answer',
      AnalyticsProperties.wasEdited: card.answerText != quizCardRequestItem.answer,
    }));
  }

  Future<void> launchQuizRequest({
    bool isQuickPlay = false,
    bool isShuffle = false,
    bool switchSides = false,
  }) async {
    final result = await quizCardExeValidator.isExeValid();

    // Use selected cards if any, otherwise use all unlocked cards
    final cards = _selectedCardIds.isEmpty
        ? List<QuizCardItem>.from(items)
        : List<QuizCardItem>.from(
            items.where((card) => _selectedCardIds.contains(card.id)));

    if (isShuffle) {
      cards.shuffle();
    }
    if (switchSides) {
      final switchedCards = <QuizCardItem>[];
      for (var card in cards) {
        switchedCards.add(
          QuizCardItem(
            id: card.id,
            questionText: card.answerText,
            answerText: card.questionText,
            deckId: card.deckId,
            isArchive: card.isArchive,
          ),
        );
      }
      cards
        ..clear()
        ..addAll(switchedCards);
    }
    if (result is QuizCardExeValid) {
      emit(
        QuizCardLaunchState(
          quizCarList: cards,
          isQuickPlay: isQuickPlay,
        ),
      );
    } else {
      emit(
        QuizCardListErrorState(
          message: (result as QuizCardExeInvalid).reason,
        ),
      );
    }
  }

  void addCardRequest() async {
    final canAddCard = await quizCardPremiumManager.canAddQuizCard(deckItem);
    emit(
      RequestCreateQuizCardState(
        canCreateCard: canAddCard,
      ),
    );
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    _deckSubscription?.cancel();
    return super.close();
  }
}

abstract class QuizCardListState extends Equatable {
  const QuizCardListState();
}

abstract class BuilderState extends QuizCardListState {
  const BuilderState();
}

abstract class ListenerState extends QuizCardListState with UniqueEmit {
  ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class QuizCardListLoadingState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class QuizCardListDataState extends BuilderState {
  const QuizCardListDataState({
    required this.quizCarList,
    this.selectedCardIds = const {},
    this.deckStats,
  });

  final List<QuizCardItem> quizCarList;
  final Set<int> selectedCardIds;
  final ItemStats? deckStats;

  bool get hasSelection => selectedCardIds.isNotEmpty;

  bool get allSelected {
    final unlockedIds = quizCarList.map((card) => card.id).toSet();
    return unlockedIds.isNotEmpty &&
        unlockedIds.every((id) => selectedCardIds.contains(id));
  }

  int get selectedCount {
    return quizCarList
        .where((card) => selectedCardIds.contains(card.id))
        .length;
  }

  @override
  List<Object?> get props => [quizCarList, selectedCardIds, deckStats];
}

class QuizCardLaunchState extends ListenerState {
  QuizCardLaunchState({
    required this.quizCarList,
    this.isQuickPlay = false,
  });

  final List<QuizCardItem> quizCarList;
  final bool isQuickPlay;
}

class RequestCreateQuizCardState extends ListenerState {
  final bool canCreateCard;

  RequestCreateQuizCardState({
    required this.canCreateCard,
  });
}

class QuizCardListErrorState extends ListenerState {
  final String message;

  QuizCardListErrorState({required this.message});
}
