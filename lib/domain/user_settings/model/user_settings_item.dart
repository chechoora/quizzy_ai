import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class UserSettingsItem {
  UserSettingsItem({
    required this.id,
    required this.userId,
    required this.answerValidatorType,
    required this.deckGenerationAiType,
    required this.geminiConfig,
    required this.claudeConfig,
    required this.openConfig,
    required this.ollamaConfig,
    required this.onboardingCompleted,
  });

  final int id;
  final int userId;
  final AnswerValidatorType answerValidatorType;
  final AnswerValidatorType deckGenerationAiType;
  final ApiKeyConfig geminiConfig;
  final ApiKeyConfig claudeConfig;
  final ApiKeyConfig openConfig;
  final OpenSourceConfig ollamaConfig;
  final bool onboardingCompleted;
}