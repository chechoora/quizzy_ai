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
    if (selectedValidator == AnswerValidatorType.onDeviceAI ||
        selectedValidator == AnswerValidatorType.ml) {
      return const QuizCardExeValid();
    }

    // Check if the selected validator has an API key configured
    ValidatorConfig? config;
    switch (selectedValidator) {
      case AnswerValidatorType.gemini:
        config = settings.geminiConfig;
        break;
      case AnswerValidatorType.claude:
        config = settings.claudeConfig;
        break;
      case AnswerValidatorType.openAI:
        config = settings.openConfig;
        break;
      case AnswerValidatorType.ollama:
        config = settings.ollamaConfig;
        break;
      case AnswerValidatorType.onDeviceAI:
      case AnswerValidatorType.ml:
        return const QuizCardExeValid();
    }

    if (config == null) {
      return QuizCardExeInvalid(
        reason: '${selectedValidator.toDisplayString()} is not configured.',
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
