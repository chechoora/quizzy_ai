import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';

class UserSettingsDataBaseRepository {
  final AppDatabase appDatabase;

  UserSettingsDataBaseRepository(this.appDatabase);

  Future<UserSettingsTableData> fetchUserSettings(int userId) async {
    final settings = await (appDatabase.select(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();

    if (settings.isNotEmpty) {
      return settings.first;
    }

    // Create default settings if they don't exist
    final result = await appDatabase.into(appDatabase.userSettingsTable).insert(
          UserSettingsTableCompanion.insert(
            userId: userId,
            answerValidatorType: const Value('gemini'),
          ),
        );

    if (result != -1) {
      final userSettings =
          await (appDatabase.select(appDatabase.userSettingsTable)
                ..where((tbl) => tbl.userId.equals(userId)))
              .getSingle();
      return userSettings;
    }

    throw Exception('Cannot fetch or create user settings for userId: $userId');
  }

  Stream<UserSettingsTableData> watchUserSettings(int userId) {
    return (appDatabase.select(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watchSingle();
  }

  Future<void> updateAnswerValidatorType(
      int userId, String validatorType) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      answerValidatorType: Value(validatorType),
    ));
  }

  Future<void> updateGeminiApiKey(int userId, String? apiKey) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      geminiApiKey: Value(apiKey),
    ));
  }

  Future<void> updateClaudeApiKey(int userId, String? apiKey) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      claudeApiKey: Value(apiKey),
    ));
  }

  Future<void> updateOpenAiApiKey(int userId, String? apiKey) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      openAiApiKey: Value(apiKey),
    ));
  }
}
