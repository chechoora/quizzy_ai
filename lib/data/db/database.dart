// These imports are necessary to open the sqlite3 database
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:poc_ai_quiz/data/db/analytics/analytics_event_table.dart';
import 'package:poc_ai_quiz/data/db/deck_table.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_table.dart';
import 'package:poc_ai_quiz/data/db/user_table.dart';
import 'package:poc_ai_quiz/data/db/user_settings_table.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  DeckTable,
  QuizCardTable,
  UserTable,
  UserSettingsTable,
  SyncTombstoneTable,
  AnalyticsEventTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Opens the database against a caller-provided [executor] instead of the
  /// on-device file. Used by migration tests to exercise [onUpgrade] against
  /// an in-memory database seeded at an older schema version.
  @visibleForTesting
  AppDatabase.withExecutor(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          // Migration for adding API key columns to user_settings_table
          await m.addColumn(userSettingsTable, userSettingsTable.geminiApiKey);
          await m.addColumn(userSettingsTable, userSettingsTable.claudeApiKey);
          await m.addColumn(userSettingsTable, userSettingsTable.openAiApiKey);
        }
        if (from < 5) {
          // Migration for adding Ollama configuration columns
          await m.addColumn(userSettingsTable, userSettingsTable.ollamaModelUrl);
          await m.addColumn(userSettingsTable, userSettingsTable.ollamaModelName);
        }
        if (from < 6) {
          // Migration for adding model name columns for API key validators
          await m.addColumn(userSettingsTable, userSettingsTable.geminiModelName);
          await m.addColumn(userSettingsTable, userSettingsTable.claudeModelName);
          await m.addColumn(userSettingsTable, userSettingsTable.openAiModelName);
        }
        if (from < 7) {
          // Migration for adding the deck generation AI selection column
          await m.addColumn(
              userSettingsTable, userSettingsTable.deckGenerationAiType);
        }
        if (from < 8) {
          // Migration for adding the onboarding completion flag
          await m.addColumn(
              userSettingsTable, userSettingsTable.onboardingCompleted);
        }
        if (from < 9) {
          // Migration for adding stable timestamp-based uid columns used for
          // idempotent iCloud backup/restore. The columns are added without a
          // UNIQUE constraint (SQLite cannot add a UNIQUE column via ALTER
          // TABLE); existing rows are backfilled with unique values derived
          // from their row id, then a unique index enforces uniqueness.
          await m.addColumn(deckTable, deckTable.uid);
          await m.addColumn(quizCardTable, quizCardTable.uid);
          final base = DateTime.now().millisecondsSinceEpoch;
          await customStatement(
            'UPDATE deck_table SET uid = $base + id WHERE uid IS NULL',
          );
          await customStatement(
            'UPDATE quiz_card_table SET uid = $base + id WHERE uid IS NULL',
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS deck_table_uid '
            'ON deck_table (uid)',
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS quiz_card_table_uid '
            'ON quiz_card_table (uid)',
          );
        }
        if (from < 10) {
          // Migration for two-way remote sync with the quizzy-ai-pro backend
          // (quizzyPro flavor only): links a local row to its remote
          // counterpart (remoteId) and tracks unpushed local changes
          // (isDirty). isDirty defaults to true so pre-existing rows are
          // picked up by the first push cycle; no manual backfill statement
          // is needed since the column DEFAULT applies on ALTER TABLE. Also
          // adds the tombstone table used to propagate local deletes.
          await m.addColumn(deckTable, deckTable.remoteId);
          await m.addColumn(deckTable, deckTable.isDirty);
          await m.addColumn(quizCardTable, quizCardTable.remoteId);
          await m.addColumn(quizCardTable, quizCardTable.isDirty);
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS deck_table_remote_id '
            'ON deck_table (remote_id)',
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS quiz_card_table_remote_id '
            'ON quiz_card_table (remote_id)',
          );
          await m.createTable(syncTombstoneTable);
        }
        if (from < 11) {
          // Migration for quizzy-ai-pro backend play stats (quizzyPro flavor
          // only). All columns are nullable with no default, so pre-existing
          // rows and every row on the local-only quizzy flavor simply read
          // back null — no backfill needed.
          await m.addColumn(deckTable, deckTable.statsAccuracyWeek);
          await m.addColumn(deckTable, deckTable.statsAccuracyMonth);
          await m.addColumn(deckTable, deckTable.statsAccuracyYear);
          await m.addColumn(deckTable, deckTable.statsAttemptsWeek);
          await m.addColumn(deckTable, deckTable.statsAttemptsMonth);
          await m.addColumn(deckTable, deckTable.statsAttemptsYear);
          await m.addColumn(deckTable, deckTable.statsBestStreakWeek);
          await m.addColumn(deckTable, deckTable.statsBestStreakMonth);
          await m.addColumn(deckTable, deckTable.statsBestStreakYear);
          await m.addColumn(deckTable, deckTable.statsLastPlayedAt);
          await m.addColumn(quizCardTable, quizCardTable.statsAccuracyWeek);
          await m.addColumn(quizCardTable, quizCardTable.statsAccuracyMonth);
          await m.addColumn(quizCardTable, quizCardTable.statsAccuracyYear);
          await m.addColumn(quizCardTable, quizCardTable.statsAttemptsWeek);
          await m.addColumn(quizCardTable, quizCardTable.statsAttemptsMonth);
          await m.addColumn(quizCardTable, quizCardTable.statsAttemptsYear);
          await m.addColumn(quizCardTable, quizCardTable.statsBestStreakWeek);
          await m.addColumn(
              quizCardTable, quizCardTable.statsBestStreakMonth);
          await m.addColumn(quizCardTable, quizCardTable.statsBestStreakYear);
          await m.addColumn(quizCardTable, quizCardTable.statsLastPlayedAt);
        }
        if (from >= 10 && from < 12) {
          // Migration for grouping card tombstones by parent deck when
          // pushing DELETE /decks/{id}/cards/batch: links each 'card'
          // tombstone to its owning deck's remote id. Guarded on `from >=
          // 10` because a device jumping straight from <10 to >=12 already
          // gets this column for free: the `from < 10` branch above creates
          // sync_tombstone_table via `m.createTable`, which builds the table
          // from the table's *current* Dart definition (already including
          // parentRemoteId), so adding the column again here would fail with
          // "duplicate column".
          await m.addColumn(
              syncTombstoneTable, syncTombstoneTable.parentRemoteId);
        }
        if (from < 13) {
          // Migration for skipping listCards + upserts on pull for a deck
          // whose remote copy hasn't changed since last seen: tracks the
          // remote deck's updatedAt as of the last successful card pull.
          await m.addColumn(deckTable, deckTable.remoteUpdatedAt);
        }
        if (from < 14) {
          // Migration for the local analytics outbox (quizzyPro flavor
          // only): queues events for POST /api/analytics/events until
          // they're accepted or dropped as unretriable.
          await m.createTable(analyticsEventTable);
        }
      },
    );
  }

  /// Wipes every row from every table. Used on sign-out / account deletion so
  /// the next user to sign in on this device starts from a clean local slate.
  Future<void> clearAllTables() async {
    await transaction(() async {
      await delete(deckTable).go();
      await delete(quizCardTable).go();
      await delete(userTable).go();
      await delete(userSettingsTable).go();
      await delete(syncTombstoneTable).go();
      await delete(analyticsEventTable).go();
    });
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
