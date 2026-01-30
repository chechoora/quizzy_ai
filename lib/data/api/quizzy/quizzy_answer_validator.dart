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
        body: {
          'question': question,
          'correct_answer': correctAnswer,
          'user_answer': userAnswer,
        },
      ),
    );
  }

  Future<AnswerResult> _answerFromResponse(Response<dynamic> response) async {
    if (response.statusCode == 200) {
      final data = response.body as Map<String, dynamic>;
      final score = (data['score'] as num).toDouble();
      final explanation = data['explanation'] as String?;
      return AnswerResult(score: score, explanation: explanation);
    } else {
      throw Exception('Failed to validate answer: ${response.statusCode}');
    }
  }
}
