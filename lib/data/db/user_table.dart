import 'package:drift/drift.dart';

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  BoolColumn get isPremium => boolean()();

  TextColumn get answerValidatorType => text().withDefault(const Constant('gemini'))();

  @override
  Set<Column> get primaryKey => {id};
}
