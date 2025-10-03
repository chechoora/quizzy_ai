import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';

class OnDeviceAIAnswerValidator implements IAnswerValidator {
  final OnDeviceAIService onDeviceAIService;

  OnDeviceAIAnswerValidator(this.onDeviceAIService);

  @override
  Future<double> validateAnswer({
    required String correctAnswer,
    required String userAnswer,
  }) async {
    final result = await onDeviceAIService.validateAnswer(
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
    );
    return result.howCorrect;
  }
}
