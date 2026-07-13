import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/model/user_settings_item.dart';

class UserSettingsDataBaseMapper {
  UserSettingsItem mapToUserSettingsItem(UserSettingsTableData data) {
    final validatorType = AnswerValidatorType.values.firstWhere(
      (e) => e.name == data.answerValidatorType,
      orElse: () => AnswerValidatorType.ml,
    );
    final deckGenerationAiType = AnswerValidatorType.values.firstWhere(
      (e) => e.name == data.deckGenerationAiType,
      orElse: () => AnswerValidatorType.claude,
    );
    return UserSettingsItem(
      id: data.id,
      userId: data.userId,
      answerValidatorType: validatorType,
      deckGenerationAiType: deckGenerationAiType,
      geminiConfig: (data.geminiApiKey != null || data.geminiModelName != null)
          ? ApiKeyConfig(
              apiKey: data.geminiApiKey ?? '',
              model: data.geminiModelName ?? '',
            )
          : ApiKeyConfig.empty(),
      claudeConfig: (data.claudeApiKey != null || data.claudeModelName != null)
          ? ApiKeyConfig(
              apiKey: data.claudeApiKey ?? '',
              model: data.claudeModelName ?? '',
            )
          : ApiKeyConfig.empty(),
      openConfig: (data.openAiApiKey != null || data.openAiModelName != null)
          ? ApiKeyConfig(
              apiKey: data.openAiApiKey ?? '',
              model: data.openAiModelName ?? '',
            )
          : ApiKeyConfig.empty(),
      ollamaConfig:
          (data.ollamaModelUrl != null && data.ollamaModelName != null)
              ? OpenSourceConfig(
                  url: data.ollamaModelUrl!,
                  model: data.ollamaModelName!,
                )
              : OpenSourceConfig.empty(),
    );
  }
}
