import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';

class QuizService {
  final IAnswerValidator answerValidator;

  QuizService(this.answerValidator);

  Future<double> isSimilarEnough({
    required String initialText,
    required String inputText,
  }) async {
    return await answerValidator.validateAnswer(
      correctAnswer: initialText,
      userAnswer: inputText,
    );
  }
}
