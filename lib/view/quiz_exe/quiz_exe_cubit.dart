import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_engine.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';

class QuizExeCubit extends Cubit<QuizExeState> {
  QuizExeCubit({
    required this.quizCardItems,
    required this.quizService,
    required this.quizMatchBuilder,
  }) : super(QuizExeLoadingState());

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
    if (quizEngine.hasNext) {
      quizEngine.nextCard();
    }
  }

  void checkTheAnswer(
    QuizCardItem quizCardItem,
    String possibleAnswer,
  ) async {
    final result = await quizEngine.checkPossibleAnswer(quizCardItem, possibleAnswer);
    quizMatchBuilder.saveResult(quizCardItem, possibleAnswer, result);
    emit(QuizCardResultState(isCorrect: result >= 0.6));
    if (quizEngine.hasNext) {
      quizEngine.nextCard();
    } else {
      emit(QuizDoneState(quizResults: quizMatchBuilder.getResults()));
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
