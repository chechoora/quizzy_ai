import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';

/// Read/purge access to pending delete tombstones. Tombstones are inserted
/// inline by [DeckDataBaseRepository.deleteDeck] /
/// [QuizCardDataBaseRepository.deleteQuizCard] within the same transaction
/// as the row delete, so this repository only needs to read and purge them.
class SyncTombstoneRepository {
  SyncTombstoneRepository(this.appDatabase);

  final AppDatabase appDatabase;

  /// Pending tombstones for the given entity type ('deck' | 'card').
  Future<List<SyncTombstoneTableData>> fetchTombstones(
      String entityType) async {
    return (appDatabase.select(appDatabase.syncTombstoneTable)
          ..where((table) => table.entityType.isValue(entityType)))
        .get();
  }

  /// Purges a tombstone once its remote delete has succeeded (or the remote
  /// confirms the row is already gone).
  Future<void> deleteTombstone(int id) async {
    await (appDatabase.delete(appDatabase.syncTombstoneTable)
          ..where((table) => table.id.isValue(id)))
        .go();
  }

  /// Emits the count of pending tombstones (deck + card combined), for the
  /// sync trigger — only moves when a delete is recorded/purged. See
  /// [DeckDataBaseRepository.watchDirtyDeckCount] for why `distinct()` is
  /// required on top of the count query itself.
  Stream<int> watchTombstoneCount() {
    final countExp = appDatabase.syncTombstoneTable.id.count();
    final query = appDatabase.selectOnly(appDatabase.syncTombstoneTable)
      ..addColumns([countExp]);
    return query.map((row) => row.read(countExp) ?? 0).watchSingle().distinct();
  }
}
