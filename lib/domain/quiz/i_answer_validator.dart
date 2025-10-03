abstract class IAnswerValidator {
  Future<double> validateAnswer({
    required String correctAnswer,
    required String userAnswer,
  });
}