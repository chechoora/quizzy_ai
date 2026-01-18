import 'package:drift/drift.dart';

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  @override
  Set<Column> get primaryKey => {id};
}
