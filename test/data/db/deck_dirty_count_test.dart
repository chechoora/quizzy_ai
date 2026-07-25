import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';

/// Regression coverage for the sync feedback-loop bug: Drift's
/// `.watchSingle()` re-runs (and re-emits) on *every* write to the watched
/// table, even when the computed value comes out identical — a pull that
/// writes new remote fields onto an already-non-dirty deck must not be seen
/// by [DeckDataBaseRepository.watchDirtyDeckCount] as "the dirty count
/// changed".
void main() {
  test(
      'watchDirtyDeckCount does not re-emit when a write does not change '
      'the dirty count', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DeckDataBaseRepository(db);

    // One dirty deck (never synced) and one already-synced, non-dirty deck.
    await db.into(db.deckTable).insert(
          DeckTableCompanion.insert(title: 'Dirty', isArchive: false),
        );
    await repo.upsertDeckByRemoteId(
      remoteId: 'r1',
      title: 'Synced v1',
      isArchive: false,
    );

    final emissions = <int>[];
    final sub = repo.watchDirtyDeckCount().listen(emissions.add);
    await Future.delayed(Duration.zero);

    // Pull-style remote-wins upserts on the already-synced (non-dirty) deck:
    // these are real writes (title changes each time) but isDirty stays
    // false throughout, so the *count* of dirty rows never moves.
    await repo.upsertDeckByRemoteId(
      remoteId: 'r1',
      title: 'Synced v2',
      isArchive: false,
    );
    await repo.upsertDeckByRemoteId(
      remoteId: 'r1',
      title: 'Synced v3',
      isArchive: false,
    );
    await Future.delayed(Duration.zero);
    await sub.cancel();

    // Only the initial emission (1 dirty deck) — the two no-op-for-the-count
    // writes above must not produce extra "count changed" events.
    expect(emissions, [1]);
  });

  test('watchDirtyDeckCount does emit when the dirty count actually changes',
      () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DeckDataBaseRepository(db);

    final emissions = <int>[];
    final sub = repo.watchDirtyDeckCount().listen(emissions.add);
    await Future.delayed(Duration.zero);

    final id = await db.into(db.deckTable).insert(
          DeckTableCompanion.insert(title: 'New deck', isArchive: false),
        );
    await repo.markDeckSynced(id, 'r2');
    await Future.delayed(Duration.zero);
    await sub.cancel();

    // 0 (initial, no rows) -> 1 (dirty insert) -> 0 (markDeckSynced clears
    // isDirty).
    expect(emissions, [0, 1, 0]);
  });
}
