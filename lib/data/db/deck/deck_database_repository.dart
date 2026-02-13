import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';

class DeckDataBaseRepository {
  final AppDatabase appDatabase;

  DeckDataBaseRepository(this.appDatabase);

  Stream<List<DeckTableData>> watchAllDecks() {
    return appDatabase.select(appDatabase.deckTable).watch();
  }

  Future<List<DeckTableData>> fetchAllDecks() {
    return appDatabase.select(appDatabase.deckTable).get();
  }

  Future<int> saveDeck(String deckName) async {
    final result = await appDatabase.into(appDatabase.deckTable).insert(
          DeckTableCompanion.insert(
            title: deckName,
            isArchive: false,
          ),
        );
    return result;
  }

  Future<List<int>> saveDecks(List<String> list) async {
    return appDatabase.transaction(() async {
      final ids = <int>[];
      for (final deckName in list) {
        final id = await appDatabase.into(appDatabase.deckTable).insert(
              DeckTableCompanion.insert(
                title: deckName,
                isArchive: false,
              ),
            );
        ids.add(id);
      }
      return ids;
    });
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
