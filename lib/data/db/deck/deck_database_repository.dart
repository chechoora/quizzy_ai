import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class DeckDataBaseRepository {
  final AppDatabase appDatabase;

  DeckDataBaseRepository(this.appDatabase);

  Future<List<DeckTableData>> fetchAllDecks() {
    return appDatabase.select(appDatabase.deckTable).get();
  }

  Future<bool> saveDeck(String deckName) async {
    final result = await appDatabase.into(appDatabase.deckTable).insert(
          DeckTableCompanion.insert(
            title: deckName,
          ),
        );
    return result != -1;
  }

  Future<bool> editDeckName(DeckItem deck, String deckName) async {
    final result = await (appDatabase.update(appDatabase.deckTable)
          ..where(
            (table) => table.id.isValue(
              deck.id,
            ),
          ))
        .write(
      DeckTableCompanion(
        title: Value(deckName),
      ),
    );
    return result >= 0;
  }

  Future<bool> deleteDeck(int id) async {
    final result = await (appDatabase.delete(appDatabase.deckTable)
          ..where(
            (table) => table.id.isValue(
              id,
            ),
          ))
        .go();
    return result >= 0;
  }
}
