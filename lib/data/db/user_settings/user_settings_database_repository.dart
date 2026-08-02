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
            answerValidatorType: const Value('ml'),
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

  /// Uses `watchSingleOrNull` (not `watchSingle`) because the row can
  /// legitimately disappear mid-stream: `LogoutManager.clearLocalData`
  /// wipes this table on sign-out / account deletion while a subscriber
  /// (e.g. `ValidatorConfigProvider`) may still be watching it.
  /// `watchSingle` would throw a fatal `StateError` at that point.
  Stream<UserSettingsTableData?> watchUserSettings(int userId) {
    return (appDatabase.select(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watchSingleOrNull();
  }

  Future<void> updateAnswerValidatorType(
      int userId, String validatorType) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      answerValidatorType: Value(validatorType),
    ));
  }

  Future<void> updateDeckGenerationAiType(int userId, String type) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      deckGenerationAiType: Value(type),
    ));
  }

  Future<void> updateGeminiConfig(
    int userId,
    String? apiKey,
    String? model,
  ) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      geminiApiKey: Value(apiKey),
      geminiModelName: Value(model),
    ));
  }

  Future<void> updateClaudeConfig(
    int userId,
    String? apiKey,
    String? model,
  ) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      claudeApiKey: Value(apiKey),
      claudeModelName: Value(model),
    ));
  }

  Future<void> updateOpenAiConfig(
    int userId,
    String? apiKey,
    String? model,
  ) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      openAiApiKey: Value(apiKey),
      openAiModelName: Value(model),
    ));
  }

  Future<void> updateOnboardingCompleted(int userId, bool completed) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      onboardingCompleted: Value(completed),
    ));
  }

  Future<void> updateShuffleEnabled(int userId, bool value) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      shuffleEnabled: Value(value),
    ));
  }

  Future<void> updateSwitchSides(int userId, bool value) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      switchSides: Value(value),
    ));
  }

  Future<void> updateIsAnswerVisible(int userId, bool value) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      isAnswerVisible: Value(value),
    ));
  }

  Future<void> updateOllamaConfig(
    int userId,
    String? url,
    String? model,
  ) async {
    await (appDatabase.update(appDatabase.userSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(UserSettingsTableCompanion(
      ollamaModelUrl: Value(url),
      ollamaModelName: Value(model),
    ));
  }
}
