import 'package:chopper/src/response.dart';
import 'package:poc_ai_quiz/data/api/quizzy/quizzy_api_service.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';

class QuizzyAnswerValidator extends IAnswerValidator {
  final QuizzyApiService _apiService;

  QuizzyAnswerValidator(this._apiService);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    return _answerFromResponse(
      await _apiService.validateAnswer(
        body: CheckAnswerRequest(
          question: question,
          correctAnswer: correctAnswer,
          userAnswer: userAnswer,
        ),
      ),
    );
  }

  Future<AnswerResult> _answerFromResponse(Response<dynamic> response) async {
    if (response.statusCode == 200) {
      final data = response.body as Map<String, dynamic>;
      final isCorrect = data['isCorrect'] as bool;
      final feedback = data['feedback'] as String?;
      final confidence = (data['confidence'] as num).toDouble();
      return AnswerResult(
        score: isCorrect ? confidence : 0.0,
        explanation: feedback,
      );
    } else {
      throw Exception('Failed to validate answer: ${response.statusCode}');
    }
  }
}