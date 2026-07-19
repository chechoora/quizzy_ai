// These imports are necessary to open the sqlite3 database
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Opens the database against a caller-provided [executor] instead of the
  /// on-device file. Used by migration tests to exercise [onUpgrade] against
  /// an in-memory database seeded at an older schema version.
  @visibleForTesting
  AppDatabase.withExecutor(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 10;

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
      },
    );
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
