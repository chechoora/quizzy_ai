import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class QuizCardExeValidator {
  const QuizCardExeValidator({
    required this.userRepository,
    required this.userSettingsRepository,
  });

  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;

  Future<QuizCardExeValidationResult> isExeValid() async {
    final user = await userRepository.fetchCurrentUser();
    final settings = await userSettingsRepository.fetchUserSettings(user.id);
    final selectedValidator = settings.answerValidatorType;

    // On-device AI doesn't need an API key
    if (selectedValidator == AnswerValidatorType.onDeviceAI) {
      return const QuizCardExeValid();
    }

    // Check if the selected validator has an API key configured
    String? apiKey;
    switch (selectedValidator) {
      case AnswerValidatorType.gemini:
        apiKey = settings.geminiApiKey;
        break;
      case AnswerValidatorType.claude:
        apiKey = settings.claudeApiKey;
        break;
      case AnswerValidatorType.openAI:
        apiKey = settings.openAiApiKey;
        break;
      case AnswerValidatorType.onDeviceAI:
      case AnswerValidatorType.ml:
        // Already handled above
        return const QuizCardExeValid();
    }

    if (apiKey == null || apiKey.isEmpty) {
      return QuizCardExeInvalid(
        reason: '${selectedValidator.toDisplayString()} requires an API key',
      );
    }

    return const QuizCardExeValid();
  }
}

sealed class QuizCardExeValidationResult {
  const QuizCardExeValidationResult();
}

class QuizCardExeValid extends QuizCardExeValidationResult {
  const QuizCardExeValid();
}

class QuizCardExeInvalid extends QuizCardExeValidationResult {
  const QuizCardExeInvalid({required this.reason});

  final String reason;
}
