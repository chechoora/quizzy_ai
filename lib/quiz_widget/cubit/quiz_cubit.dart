import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/quiz_serive/quiz_service.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this.quizService) : super(QuizState());

  final QuizService quizService;

  Future<void> checkText({
    required String initialText,
    required String inputText,
  }) async {
    final bool isSimilarEnough = await quizService.isSimilarEnough(initialText: initialText, inputText: inputText);
    emit(QuizResultState(isSimilarEnough));
  }
}

class QuizState {}

class QuizResultState extends QuizState {
  final bool isSimilarEnough;

  QuizResultState(this.isSimilarEnough);
}
