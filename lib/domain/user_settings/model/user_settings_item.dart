import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class UserSettingsItem {
  UserSettingsItem({
    required this.id,
    required this.userId,
    required this.answerValidatorType,
  });

  final int id;
  final int userId;
  final AnswerValidatorType answerValidatorType;
}