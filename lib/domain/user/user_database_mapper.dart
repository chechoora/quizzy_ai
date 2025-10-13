import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/model/user_item.dart';

class UserDataBaseMapper {

  UserItem mapToUserItem(UserTableData data) {
    final validatorType = AnswerValidatorType.values.firstWhere(
      (e) => e.name == data.answerValidatorType,
      orElse: () => AnswerValidatorType.gemini,
    );
    return UserItem(data.id, data.isPremium, validatorType);
  }

}
