import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/user_table.dart';

class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(UserTable, #id)();

  TextColumn get answerValidatorType => text().withDefault(const Constant('ml'))();

  TextColumn get deckGenerationAiType =>
      text().withDefault(const Constant('claude'))();

  TextColumn get geminiApiKey => text().nullable()();

  TextColumn get geminiModelName => text().nullable()();

  TextColumn get claudeApiKey => text().nullable()();

  TextColumn get claudeModelName => text().nullable()();

  TextColumn get openAiApiKey => text().nullable()();

  TextColumn get openAiModelName => text().nullable()();

  TextColumn get ollamaModelUrl => text().nullable()();

  TextColumn get ollamaModelName => text().nullable()();

  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
}