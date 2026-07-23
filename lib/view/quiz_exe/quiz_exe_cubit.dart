import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/initial_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_engine.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class QuizExeCubit extends Cubit<QuizExeState> {
  QuizExeCubit({
    required this.quizCardItems,
    required this.quizService,
    required this.quizMatchBuilder,
    required this.settingsService,
    required this.validatorsManager,
    required this.initialAnswerValidator,
    required this.deckCardSyncService,
    this.isQuickPlay = false,
  }) : super(QuizExeLoadingState());

  final InitialAnswerValidator initialAnswerValidator;
  final List<QuizCardItem> quizCardItems;
  final QuizService quizService;
  final QuizMatchBuilder quizMatchBuilder;
  final SettingsService settingsService;
  final ValidatorsManager validatorsManager;
  final DeckCardSyncService deckCardSyncService;
  final bool isQuickPlay;

  final _logger = Logger.withTag('QuizExeCubit');

  late final quizEngine = QuizEngine(
    cards: quizCardItems,
    quizService: quizService,
    onTestNewCard: (card, index, total) async {
      emit(QuizExeDisplayCardState(
        quizCardItem: card,
        currentIndex: index,
        totalCards: total,
      ));
    },
  );

  void launchQuiz() {
    _logger.d('Launching quiz with ${quizCardItems.length} cards');
    if (quizEngine.hasNext) {
      quizEngine.nextCard();
    }
  }

  void checkTheAnswer(
    QuizCardItem quizCardItem,
    String possibleAnswer,
  ) async {
    final lastDisplayState = state as QuizExeDisplayCardState;
    try {
      _logger.d('Checking answer for card: ${quizCardItem.id}');
      emit(lastDisplayState.copyWith(
        isProcessing: true,
      ));

      // Validate answer before sending to AI
      final validationResult = initialAnswerValidator.validate(possibleAnswer);
      if (!validationResult.isValid) {
        _logger.w(
            'Initial answer validation failed: ${validationResult.errorMessage}');
        emit(QuizExeErrorState());

        // Restore display card state
        emit(lastDisplayState.copyWith(
          isProcessing: false,
        ));
        return;
      }

      final result =
          await quizEngine.checkPossibleAnswer(quizCardItem, possibleAnswer);
      _logger.i('Answer validation result: $result (threshold: 0.6)');
      quizMatchBuilder.saveResult(
        quizCardItem,
        possibleAnswer,
        result.score,
        result.explanation,
      );
      if (isQuickPlay) {
        _logger.d('Quick play mode, show result briefly');
        emit(QuizCardResultState(answerResult: result));
        return;
      }
      nextCard();
    } catch (e, stackTrace) {
      _logger.e('Error checking answer for card: ${quizCardItem.id}',
          ex: e, stacktrace: stackTrace);
      emit(QuizExeErrorState());

      emit(lastDisplayState);
    }
  }

  void nextCard() {
    if (quizEngine.hasNext) {
      _logger.d('Moving to next card');
      quizEngine.nextCard();
    } else {
      final results = quizMatchBuilder.getResults();
      _logger.i('Quiz completed. Results: $results');
      emit(QuizDoneState(quizResults: results));
    }
  }

  /// Answer checks record stats server-side (via the `cardId` passed to the
  /// validator), so the locally-cached deck/card stats are stale until the
  /// next pull. Re-pull as the screen is torn down (rather than right after
  /// the last answer) so it doesn't race the quiz-done UI, and still lands
  /// before the user is back on the deck screen.
  ///
  /// `close()` runs synchronously inside Flutter's element-unmount phase
  /// (`BuildOwner.finalizeTree`), while the widget tree is locked. Kicking off
  /// the pull here directly would flip `DeckCardSyncService.isSyncing`
  /// synchronously and crash any listening `ValueListenableBuilder` with
  /// "setState() called when widget tree was locked". Deferring to a
  /// microtask lets the current frame's unmount phase finish and the lock
  /// release before the pull (and its `isSyncing` notification) starts.
  @override
  Future<void> close() {
    scheduleMicrotask(() => unawaited(_pullFreshStats()));
    return super.close();
  }

  Future<void> _pullFreshStats() async {
    _logger.d('_pullFreshStats: pulling remote changes on cubit close');
    try {
      final result = await deckCardSyncService.pullRemoteChanges();
      _logger.i('_pullFreshStats: complete, $result');
    } catch (e, stackTrace) {
      _logger.e('_pullFreshStats: failed', ex: e, stacktrace: stackTrace);
    }
  }
}

abstract class QuizExeState {}

class QuizExeLoadingState extends QuizExeState {}

class QuizExeDisplayCardState extends QuizExeState {
  QuizExeDisplayCardState({
    required this.quizCardItem,
    this.isProcessing = false,
    this.currentIndex = 0,
    this.totalCards = 0,
  });

  final QuizCardItem quizCardItem;
  final bool isProcessing;
  final int currentIndex;
  final int totalCards;

  QuizExeDisplayCardState copyWith({
    QuizCardItem? quizCardItem,
    bool? isProcessing,
    int? currentIndex,
    int? totalCards,
  }) {
    return QuizExeDisplayCardState(
      quizCardItem: quizCardItem ?? this.quizCardItem,
      isProcessing: isProcessing ?? this.isProcessing,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCards: totalCards ?? this.totalCards,
    );
  }
}

class QuizCardResultState extends QuizExeState {
  QuizCardResultState({
    required this.answerResult,
  });

  final AnswerResult answerResult;
}

class QuizDoneState extends QuizExeState {
  QuizDoneState({required this.quizResults});

  final QuizResults quizResults;
}

class QuizExeErrorState extends QuizExeState {
  QuizExeErrorState();
}
