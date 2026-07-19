import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/util/uid_generator.dart';

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
            uid: Value(UidGenerator.next()),
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
                uid: Value(UidGenerator.next()),
              ),
            );
        ids.add(id);
      }
      return ids;
    });
  }

  /// Returns the local row id of the deck with the given [uid], or null.
  Future<int?> findDeckIdByUid(int uid) async {
    final row = await (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.uid.isValue(uid))
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  /// Inserts a deck preserving its backup [uid] (used by iCloud restore).
  Future<int> saveDeckWithUid(String title, int uid) async {
    return appDatabase.into(appDatabase.deckTable).insert(
          DeckTableCompanion.insert(
            title: title,
            isArchive: false,
            uid: Value(uid),
          ),
        );
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
