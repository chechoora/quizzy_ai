import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/user/user_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user_settings/user_settings_database_repository.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/user/user_database_mapper.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_database_mapper.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

/// Regression coverage for the "logged-in subscriber stuck on the `ml`
/// default" bug: [UserSettingsDataBaseRepository]'s `update*` methods are
/// bare UPDATEs that silently no-op when no row exists yet for the userId.
/// [SettingsService.initUserRecords] must create both the user row and its
/// settings row up front (right after login, before anything else writes
/// into settings) so that a subsequent `updateValidatorType` actually
/// persists instead of being lost.
void main() {
  test('initUserRecords creates a settings row a later update can persist to',
      () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);

    final userRepository = UserRepository(
      dataBaseRepository: UserDataBaseRepository(db),
      userDataBaseMapper: UserDataBaseMapper(),
    );
    final userSettingsRepository = UserSettingsRepository(
      dataBaseRepository: UserSettingsDataBaseRepository(db),
      userSettingsDataBaseMapper: UserSettingsDataBaseMapper(),
    );
    final settingsService = SettingsService(
      userRepository: userRepository,
      userSettingsRepository: userSettingsRepository,
      validators: const {},
      enableByok: true,
    );

    // Nothing has touched the DB yet — no userTable/userSettingsTable rows.
    await settingsService.initUserRecords();

    // Without initUserRecords having run first, this update would silently
    // no-op against a nonexistent row (see user_settings_database_repository_test.dart).
    await settingsService.updateValidatorType(AnswerValidatorType.quizzyAI);

    expect(
      await settingsService.getCurrentValidatorType(),
      AnswerValidatorType.quizzyAI,
    );
  });
}
