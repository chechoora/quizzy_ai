import 'package:poc_ai_quiz/data/api/on_device_ai/generated/on_device_ai.g.dart';

class OnDeviceAIService {
  OnDeviceAIService({OnDeviceAiApi? api}) : _api = api ?? OnDeviceAiApi();

  final OnDeviceAiApi _api;

  /// Check if on-device AI is available on this platform
  Future<bool> isOnDeviceAIAvailable() async {
    try {
      return await _api.isOnDeviceAIAvailable();
    } catch (e) {
      // If there's an error (e.g., no native implementation), assume not available
      return false;
    }
  }

  /// Validate a user's answer against the correct answer using on-device AI
  Future<CardAnswerResult> validateAnswer({
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    return await _api.validateAnswer(question, userAnswer, correctAnswer);
  }
}
