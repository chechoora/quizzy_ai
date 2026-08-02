import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/user_settings/user_settings_database_repository.dart';

/// [UserSettingsDataBaseRepository]'s `update*` methods are bare
/// `UPDATE ... WHERE userId = X` calls with no insert fallback: if no row
/// has been created yet for that userId (e.g. nothing has called
/// `fetchUserSettings` yet), the write silently affects 0 rows and is lost.
/// This is why `SettingsService.initUserRecords` (called right after login,
/// before anything else touches user settings) must run first — see
/// `settings_service_test.dart`. This test documents that contract at the
/// repository layer.
void main() {
  test('updateAnswerValidatorType is a silent no-op when no row exists yet',
      () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserSettingsDataBaseRepository(db);

    await repo.updateAnswerValidatorType(1, 'quizzyAI');

    final settings = await repo.fetchUserSettings(1);
    // The update above was lost; fetchUserSettings lazily created a fresh
    // default row instead of reading back the (nonexistent) update.
    expect(settings.answerValidatorType, 'ml');
  });

  test('updateAnswerValidatorType persists once the row has been created',
      () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserSettingsDataBaseRepository(db);

    await repo.fetchUserSettings(1);
    await repo.updateAnswerValidatorType(1, 'quizzyAI');

    final settings = await repo.fetchUserSettings(1);
    expect(settings.answerValidatorType, 'quizzyAI');
  });

  test(
      'shuffleEnabled, switchSides and isAnswerVisible default to false and '
      'persist once set', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserSettingsDataBaseRepository(db);

    final defaults = await repo.fetchUserSettings(1);
    expect(defaults.shuffleEnabled, false);
    expect(defaults.switchSides, false);
    expect(defaults.isAnswerVisible, false);

    await repo.updateShuffleEnabled(1, true);
    await repo.updateSwitchSides(1, true);
    await repo.updateIsAnswerVisible(1, true);

    final settings = await repo.fetchUserSettings(1);
    expect(settings.shuffleEnabled, true);
    expect(settings.switchSides, true);
    expect(settings.isAnswerVisible, true);
  });
}
