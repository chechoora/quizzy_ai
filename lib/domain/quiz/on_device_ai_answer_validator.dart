import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class OnDeviceAIAnswerValidator extends IAnswerValidator {
  final _logger = Logger.withTag('OnDeviceAIAnswerValidator');
  final OnDeviceAIService onDeviceAIService;

  OnDeviceAIAnswerValidator(this.onDeviceAIService);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    _logger.d('Validating answer with on-device AI');
    _logger.v('Question: $question');
    try {
      final result = await onDeviceAIService.validateAnswer(
        question: question,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
      );
      _logger.i('On-device AI validation score: ${result.howCorrect}');
      return AnswerResult(
        correctAnswer: correctAnswer,
        score: result.howCorrect,
        explanation: result.reasoning,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to validate answer with on-device AI',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
