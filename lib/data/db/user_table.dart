import 'package:drift/drift.dart';

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  BoolColumn get isPremium => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
