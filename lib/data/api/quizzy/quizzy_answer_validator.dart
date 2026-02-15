import 'package:chopper/src/response.dart';
import 'package:poc_ai_quiz/data/api/quizzy/quizzy_api_service.dart';
import 'package:poc_ai_quiz/domain/exception/answer_validator_exception.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';

class QuizzyAnswerValidator extends IAnswerValidator {
  final QuizzyApiService _apiService;
  final InAppPurchaseService _inAppPurchaseService;

  QuizzyAnswerValidator(this._apiService, this._inAppPurchaseService);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    final appUserId = await _inAppPurchaseService.getAppUserId();
    return _answerFromResponse(
      correctAnswer,
      await _apiService.validateAnswer(
        userId: appUserId,
        body: CheckAnswerRequest(
          question: question,
          correctAnswer: correctAnswer,
          userAnswer: userAnswer,
        ),
      ),
    );
  }

  Future<AnswerResult> _answerFromResponse(
      String correctAnswer, Response<dynamic> response) async {
    if (response.statusCode == 200) {
      final data = response.body as Map<String, dynamic>;
      final isCorrect = data['isCorrect'] as bool;
      final feedback = data['feedback'] as String?;
      final confidence = (data['confidence'] as num).toDouble();
      return AnswerResult(
        correctAnswer: correctAnswer,
        score: isCorrect ? confidence : 0.0,
        explanation: feedback,
      );
    } else {
      throw AnswerValidatorException(
          'Failed to validate answer: ${response.statusCode}, ${response.error}');
    }
  }
}
