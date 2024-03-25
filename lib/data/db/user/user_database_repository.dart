import 'package:poc_ai_quiz/data/db/database.dart';

class UserDataBaseRepository {
  final AppDatabase appDatabase;

  UserDataBaseRepository(this.appDatabase);

  Future<UserTableData> fetchCurrentUser() async {
    final users = await appDatabase.select(appDatabase.userTable).get();
    if (users.isNotEmpty) {
      return users.first;
    }
    final result = await appDatabase.into(appDatabase.userTable).insert(UserTableCompanion.insert(isPremium: false));
    if (result != -1) {
      final user = (await appDatabase.select(appDatabase.userTable).get()).first;
      return user;
    }
    throw Exception('Can not fetch current user');
  }
}
