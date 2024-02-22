import 'package:drift/drift.dart';

class DeckTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 3)();

  @override
  Set<Column> get primaryKey => {id};
}

class QuizCardTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get deckId => integer().references(DeckTable, #id)();

  TextColumn get questionText => text().withLength(min: 3)();

  TextColumn get answerText => text().withLength(min: 3)();

  @override
  Set<Column> get primaryKey => {id};
}
