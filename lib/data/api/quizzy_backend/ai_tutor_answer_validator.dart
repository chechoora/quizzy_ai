import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/ai_tutor_repository.dart';

class AiTutorAnswerValidator extends IAnswerValidator {
  final AiTutorRepository _repository;

  AiTutorAnswerValidator(this._repository);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    final result = await _repository.checkAnswer(
      question: question,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
    );
    return AnswerResult(
      correctAnswer: correctAnswer,
      score: result.isCorrect ? result.confidence : 0.0,
      explanation: result.feedback,
    );
  }
}
