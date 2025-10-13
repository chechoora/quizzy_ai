import 'package:poc_ai_quiz/data/db/user/user_database_repository.dart';
import 'package:poc_ai_quiz/domain/user/model/user_item.dart';
import 'package:poc_ai_quiz/domain/user/user_database_mapper.dart';

class UserRepository {
  final UserDataBaseRepository dataBaseRepository;
  final UserDataBaseMapper userDataBaseMapper;

  UserRepository({
    required this.dataBaseRepository,
    required this.userDataBaseMapper,
  });

  Future<UserItem> fetchCurrentUser() async {
    final dbUser = await dataBaseRepository.fetchCurrentUser();
    return userDataBaseMapper.mapToUserItem(dbUser);
  }
}
