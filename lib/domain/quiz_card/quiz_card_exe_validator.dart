import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class QuizCardExeValidator {
  const QuizCardExeValidator({
    required this.userRepository,
    required this.userSettingsRepository,
    required this.inAppPurchaseService,
  });

  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  final InAppPurchaseService inAppPurchaseService;

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
      case AnswerValidatorType.quizzyAI:
        return await inAppPurchaseService
                .isFeaturePurchased(InAppPurchaseFeature.quizzyAi)
            ? const QuizCardExeValid()
            : const QuizCardExeInvalidNotPurchased(
                feature: InAppPurchaseFeature.quizzyAi,
              );
    }

    if (!config.isValid) {
      return QuizCardExeInvalidConfig(validatorType: selectedValidator);
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

sealed class QuizCardExeInvalid extends QuizCardExeValidationResult {
  const QuizCardExeInvalid();
}

class QuizCardExeInvalidNotPurchased extends QuizCardExeInvalid {
  const QuizCardExeInvalidNotPurchased({
    required this.feature,
  });

  final InAppPurchaseFeature feature;
}

class QuizCardExeInvalidConfig extends QuizCardExeInvalid {
  const QuizCardExeInvalidConfig({required this.validatorType});

  final AnswerValidatorType validatorType;
}
