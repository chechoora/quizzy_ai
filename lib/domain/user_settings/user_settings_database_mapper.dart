import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/model/user_settings_item.dart';

class UserSettingsDataBaseMapper {
  UserSettingsItem mapToUserSettingsItem(UserSettingsTableData data) {
    final validatorType = AnswerValidatorType.values.firstWhere(
      (e) => e.name == data.answerValidatorType,
      orElse: () => AnswerValidatorType.ml,
    );
    return UserSettingsItem(
      id: data.id,
      userId: data.userId,
      answerValidatorType: validatorType,
      geminiApiKey: data.geminiApiKey,
      claudeApiKey: data.claudeApiKey,
      openAiApiKey: data.openAiApiKey,
    );
  }
}
