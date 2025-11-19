import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_engine.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class QuizExeCubit extends Cubit<QuizExeState> {
  QuizExeCubit({
    required this.quizCardItems,
    required this.quizService,
    required this.quizMatchBuilder,
  }) : super(QuizExeLoadingState());

  final _logger = Logger.withTag('QuizExeCubit');
  final List<QuizCardItem> quizCardItems;
  final QuizService quizService;
  final QuizMatchBuilder quizMatchBuilder;

  late final quizEngine = QuizEngine(
    cards: quizCardItems,
    quizService: quizService,
    onTestNewCard: (card) {
      emit(
        QuizExeDisplayCardState(
          quizCardItem: card,
        ),
      );
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
    try {
      _logger.d('Checking answer for card: ${quizCardItem.id}');
      final result =
          await quizEngine.checkPossibleAnswer(quizCardItem, possibleAnswer);
      _logger.i('Answer validation result: $result (threshold: 0.6)');
      quizMatchBuilder.saveResult(quizCardItem, possibleAnswer, result);
      emit(QuizCardResultState(isCorrect: result >= 0.6));
      if (quizEngine.hasNext) {
        _logger.d('Moving to next card');
        quizEngine.nextCard();
      } else {
        final results = quizMatchBuilder.getResults();
        _logger.i('Quiz completed. Results: $results');
        emit(QuizDoneState(quizResults: results));
      }
    } catch (e, stackTrace) {
      _logger.e('Error checking answer for card: ${quizCardItem.id}',
          ex: e, stacktrace: stackTrace);
      emit(QuizExeErrorState(
        message: 'Failed to validate answer: ${e.toString()}',
        quizCardItem: quizCardItem,
      ));
      emit(
        QuizExeDisplayCardState(
          quizCardItem: quizCardItem,
        ),
      );
    }
  }
}

abstract class QuizExeState {}

class QuizExeLoadingState extends QuizExeState {}

class QuizExeDisplayCardState extends QuizExeState {
  QuizExeDisplayCardState({
    required this.quizCardItem,
  });

  final QuizCardItem quizCardItem;
}

class QuizCardResultState extends QuizExeState {
  QuizCardResultState({
    required this.isCorrect,
  });

  final bool isCorrect;
}

class QuizDoneState extends QuizExeState {
  QuizDoneState({required this.quizResults});

  final QuizResults quizResults;
}

class QuizExeErrorState extends QuizExeState {
  QuizExeErrorState({
    required this.message,
    required this.quizCardItem,
  });

  final String message;
  final QuizCardItem quizCardItem;
}
