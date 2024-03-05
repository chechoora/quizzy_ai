import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_engine.dart';
import 'package:poc_ai_quiz/domain/quiz_service.dart';

class QuizExeCubit extends Cubit<QuizExeState> {
  QuizExeCubit({
    required this.quizCardItems,
    required this.quizService,
  }) : super(QuizExeLoadingState());

  final List<QuizCardItem> quizCardItems;
  final QuizService quizService;

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

  void checkTheAnswer(
    QuizCardItem quizCardItem,
    String possibleAnswer,
  ) async {
    final result = await quizEngine.checkPossibleAnswer(quizCardItem, possibleAnswer);
    emit(QuizCardResultState(isCorrect: result >= 0.6));
    if (quizEngine.hasNext) {
      quizEngine.nextCard();
    } else {
      emit(QuizCardDoneState());
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

class QuizCardDoneState extends QuizExeState {}
