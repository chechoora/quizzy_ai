import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';
import 'package:poc_ai_quiz/util/uid_generator.dart';

class DeckDataBaseRepository {
  final AppDatabase appDatabase;

  static const _listEquality = ListEquality<DeckTableData>();

  DeckDataBaseRepository(this.appDatabase);

  /// `.watch()` re-emits on every write to the table, including no-op
  /// updates that write back identical values (e.g. sync's remote-wins
  /// upsert). `distinct()` needs an explicit equality here because
  /// `List<DeckTableData>`'s default `==` is identity, not element-wise —
  /// without it every emission is a new list instance and distinct() never
  /// suppresses anything, defeating its purpose.
  Stream<List<DeckTableData>> watchAllDecks() {
    return appDatabase
        .select(appDatabase.deckTable)
        .watch()
        .distinct(_listEquality.equals);
  }

  Future<List<DeckTableData>> fetchAllDecks() {
    return appDatabase.select(appDatabase.deckTable).get();
  }

  /// Watches the single deck [id] (its title, stats, etc.), so a screen
  /// showing one deck can stay live as stats get synced in. Emits `null` if
  /// the deck is deleted. Drift-generated row data classes already have
  /// field-wise `==`, so `distinct()` needs no explicit equality here, unlike
  /// the list-returning watch methods above.
  Stream<DeckTableData?> watchDeck(int id) {
    return (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.id.isValue(id)))
        .watchSingleOrNull()
        .distinct();
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
        isDirty: const Value(true),
      ),
    );
    return result >= 0;
  }

  /// Deletes the deck and its child cards in one transaction. When
  /// [recordTombstone] is true (the default), any child card and the deck
  /// itself that already have a [remoteId] get a [SyncTombstoneTable] entry
  /// so the delete can be propagated to the backend. Pull-side reconciliation
  /// passes `recordTombstone: false` since the remote is already the source
  /// of truth in that case (nothing to tell it).
  Future<bool> deleteDeck(int id, {bool recordTombstone = true}) async {
    return appDatabase.transaction(() async {
      final deck = await (appDatabase.select(appDatabase.deckTable)
            ..where((table) => table.id.isValue(id)))
          .getSingleOrNull();
      if (deck == null) return false;

      final cards = await (appDatabase.select(appDatabase.quizCardTable)
            ..where((table) => table.deckId.isValue(id)))
          .get();

      if (recordTombstone) {
        for (final card in cards) {
          final cardRemoteId = card.remoteId;
          if (cardRemoteId != null) {
            await appDatabase.into(appDatabase.syncTombstoneTable).insert(
                  SyncTombstoneTableCompanion.insert(
                    entityType: 'card',
                    remoteId: cardRemoteId,
                    parentRemoteId: Value(deck.remoteId),
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      }

      await (appDatabase.delete(appDatabase.quizCardTable)
            ..where((table) => table.deckId.isValue(id)))
          .go();

      final deckRemoteId = deck.remoteId;
      if (recordTombstone && deckRemoteId != null) {
        await appDatabase.into(appDatabase.syncTombstoneTable).insert(
              SyncTombstoneTableCompanion.insert(
                entityType: 'deck',
                remoteId: deckRemoteId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final result = await (appDatabase.delete(appDatabase.deckTable)
            ..where((table) => table.id.isValue(id)))
          .go();
      return result >= 0;
    });
  }

  /// Local rows with unpushed changes (new inserts default to dirty).
  Future<List<DeckTableData>> fetchDirtyDecks() async {
    return (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.isDirty.equals(true)))
        .get();
  }

  /// Emits the count of local rows with unpushed changes. Unlike
  /// [watchAllDecks], this only moves when the *number* of dirty rows
  /// changes — a remote-wins pull writes `isDirty: false`, so it never
  /// re-triggers this stream, breaking the sync feedback loop. `distinct()`
  /// is required on top of the count query itself: Drift's `.watchSingle()`
  /// re-runs and re-emits on *every* write to the underlying table (e.g. a
  /// pull writing new stats onto an already-non-dirty row), even when the
  /// computed count value comes out identical — `distinct()` is what
  /// actually suppresses the no-op re-emissions.
  Stream<int> watchDirtyDeckCount() {
    final countExp = appDatabase.deckTable.id.count();
    final query = appDatabase.selectOnly(appDatabase.deckTable)
      ..addColumns([countExp])
      ..where(appDatabase.deckTable.isDirty.equals(true));
    return query.map((row) => row.read(countExp) ?? 0).watchSingle().distinct();
  }

  /// Local rows already linked to a remote deck.
  Future<List<DeckTableData>> fetchSyncedDecks() async {
    return (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.remoteId.isNotNull()))
        .get();
  }

  /// Returns the local row id of the deck with the given [remoteId], or null.
  Future<int?> findDeckIdByRemoteId(String remoteId) async {
    final row = await (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.remoteId.isValue(remoteId))
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  /// Records the remote deck's `updatedAt` and `lastActivityAt` as of a
  /// successful card pull, so the next pull can skip `listCards` for this
  /// deck entirely if neither has changed remotely — see
  /// [DeckTable.remoteUpdatedAt] for why both are tracked.
  Future<void> updateRemoteSyncMarkers(
    int id, {
    required DateTime remoteUpdatedAt,
    required DateTime remoteLastActivityAt,
  }) async {
    await (appDatabase.update(appDatabase.deckTable)
          ..where((table) => table.id.isValue(id)))
        .write(
      DeckTableCompanion(
        remoteUpdatedAt: Value(remoteUpdatedAt),
        remoteLastActivityAt: Value(remoteLastActivityAt),
      ),
    );
  }

  /// Marks a local deck as pushed: links it to [remoteId] and clears the
  /// dirty flag.
  Future<void> markDeckSynced(int id, String remoteId) async {
    await (appDatabase.update(appDatabase.deckTable)
          ..where((table) => table.id.isValue(id)))
        .write(
      DeckTableCompanion(
        remoteId: Value(remoteId),
        isDirty: const Value(false),
      ),
    );
  }

  /// Upserts a local deck by [remoteId] (pull-side, remote wins): updates
  /// the matching local row's fields if found, otherwise inserts a new one.
  /// Returns the local row id. Skips the write entirely (no-op) when an
  /// existing, non-dirty row's content already matches incoming values —
  /// this both avoids a pointless write and keeps [watchDirtyDeckCount] (and
  /// every other table watcher) from re-emitting for a pull that changed
  /// nothing.
  Future<int> upsertDeckByRemoteId({
    required String remoteId,
    required String title,
    required bool isArchive,
    ItemStats? stats,
  }) async {
    final existing = await (appDatabase.select(appDatabase.deckTable)
          ..where((table) => table.remoteId.isValue(remoteId))
          ..limit(1))
        .getSingleOrNull();
    final statsCompanion = _statsCompanion(stats);
    if (existing != null) {
      if (!existing.isDirty &&
          existing.title == title &&
          existing.isArchive == isArchive &&
          _statsUnchanged(existing, stats)) {
        return existing.id;
      }
      await (appDatabase.update(appDatabase.deckTable)
            ..where((table) => table.id.isValue(existing.id)))
          .write(
        DeckTableCompanion(
          title: Value(title),
          isArchive: Value(isArchive),
          isDirty: const Value(false),
          statsAccuracyWeek: statsCompanion.statsAccuracyWeek,
          statsAccuracyMonth: statsCompanion.statsAccuracyMonth,
          statsAccuracyYear: statsCompanion.statsAccuracyYear,
          statsAttemptsWeek: statsCompanion.statsAttemptsWeek,
          statsAttemptsMonth: statsCompanion.statsAttemptsMonth,
          statsAttemptsYear: statsCompanion.statsAttemptsYear,
          statsBestStreakWeek: statsCompanion.statsBestStreakWeek,
          statsBestStreakMonth: statsCompanion.statsBestStreakMonth,
          statsBestStreakYear: statsCompanion.statsBestStreakYear,
          statsLastPlayedAt: statsCompanion.statsLastPlayedAt,
        ),
      );
      return existing.id;
    }
    return appDatabase.into(appDatabase.deckTable).insert(
          DeckTableCompanion.insert(
            title: title,
            isArchive: isArchive,
            uid: Value(UidGenerator.next()),
            remoteId: Value(remoteId),
            isDirty: const Value(false),
            statsAccuracyWeek: statsCompanion.statsAccuracyWeek,
            statsAccuracyMonth: statsCompanion.statsAccuracyMonth,
            statsAccuracyYear: statsCompanion.statsAccuracyYear,
            statsAttemptsWeek: statsCompanion.statsAttemptsWeek,
            statsAttemptsMonth: statsCompanion.statsAttemptsMonth,
            statsAttemptsYear: statsCompanion.statsAttemptsYear,
            statsBestStreakWeek: statsCompanion.statsBestStreakWeek,
            statsBestStreakMonth: statsCompanion.statsBestStreakMonth,
            statsBestStreakYear: statsCompanion.statsBestStreakYear,
            statsLastPlayedAt: statsCompanion.statsLastPlayedAt,
          ),
        );
  }

  /// Whether [existing]'s ten stats columns already match incoming [stats]
  /// (a `null` [stats] means every column should already be null).
  bool _statsUnchanged(DeckTableData existing, ItemStats? stats) {
    return existing.statsAccuracyWeek == stats?.accuracy.week &&
        existing.statsAccuracyMonth == stats?.accuracy.month &&
        existing.statsAccuracyYear == stats?.accuracy.year &&
        existing.statsAttemptsWeek == stats?.attempts.week &&
        existing.statsAttemptsMonth == stats?.attempts.month &&
        existing.statsAttemptsYear == stats?.attempts.year &&
        existing.statsBestStreakWeek == stats?.bestStreak.week &&
        existing.statsBestStreakMonth == stats?.bestStreak.month &&
        existing.statsBestStreakYear == stats?.bestStreak.year &&
        existing.statsLastPlayedAt == stats?.lastPlayedAt;
  }

  /// Builds the ten stats columns of a [DeckTableCompanion] from [stats],
  /// writing explicit nulls when absent so a stats-less pull result clears
  /// any stale value from a previous sync.
  DeckTableCompanion _statsCompanion(ItemStats? stats) {
    return DeckTableCompanion(
      statsAccuracyWeek: Value(stats?.accuracy.week),
      statsAccuracyMonth: Value(stats?.accuracy.month),
      statsAccuracyYear: Value(stats?.accuracy.year),
      statsAttemptsWeek: Value(stats?.attempts.week),
      statsAttemptsMonth: Value(stats?.attempts.month),
      statsAttemptsYear: Value(stats?.attempts.year),
      statsBestStreakWeek: Value(stats?.bestStreak.week),
      statsBestStreakMonth: Value(stats?.bestStreak.month),
      statsBestStreakYear: Value(stats?.bestStreak.year),
      statsLastPlayedAt: Value(stats?.lastPlayedAt),
    );
  }
}
