import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class UserItem {
  UserItem(this.id, this.isPremium, this.answerValidatorType);

  final int id;
  final bool isPremium;
  final AnswerValidatorType answerValidatorType;
}
