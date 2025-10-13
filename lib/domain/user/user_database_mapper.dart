import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/user/model/user_item.dart';

class UserDataBaseMapper {

  UserItem mapToUserItem(UserTableData data) {
    return UserItem(data.id, data.isPremium);
  }

}
