import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this.quizService) : super(const QuizIdleState());

  final QuizService quizService;

  Future<void> checkText({
    required String question,
    required String initialText,
    required String inputText,
  }) async {
    final bool isSimilarEnough = (await quizService.isSimilarEnough(
          question: question,
          initialText: initialText,
          inputText: inputText,
        ))
            .score >=
        0.7;
    emit(QuizResultState(isSimilarEnough));
  }
}

abstract class QuizState {
  const QuizState();
}

class QuizIdleState extends QuizState {
  const QuizIdleState();
}

class QuizResultState extends QuizState {
  final bool isSimilarEnough;

  const QuizResultState(this.isSimilarEnough);
}
