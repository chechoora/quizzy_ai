import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class UserSettingsItem {
  UserSettingsItem({
    required this.id,
    required this.userId,
    required this.answerValidatorType,
    required this.geminiApiKey,
    required this.claudeApiKey,
    required this.openAiApiKey,
  });

  final int id;
  final int userId;
  final AnswerValidatorType answerValidatorType;
  final String? geminiApiKey;
  final String? claudeApiKey;
  final String? openAiApiKey;
}