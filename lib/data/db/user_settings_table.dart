import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/user_table.dart';

class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(UserTable, #id)();

  TextColumn get answerValidatorType => text().withDefault(const Constant('gemini'))();

  TextColumn get geminiApiKey => text().nullable()();

  TextColumn get claudeApiKey => text().nullable()();

  TextColumn get openAiApiKey => text().nullable()();
}