import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Seeds an in-memory sqlite3 database matching the on-disk shape of schema
/// v9 (i.e. every column added by migrations up to and including v9, none of
/// the v10 sync columns/table), then opens it with [AppDatabase] so drift's
/// real `onUpgrade` runs against it — exercising the same code path a real
/// device upgrade takes.
NativeDatabase _seedV9Database() {
  final raw = sqlite3.sqlite3.openInMemory();
  raw.execute('''
    CREATE TABLE deck_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      title TEXT NOT NULL,
      is_archive INTEGER NOT NULL
    );
  ''');
  raw.execute('''
    CREATE TABLE quiz_card_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      deck_id INTEGER NOT NULL REFERENCES deck_table (id),
      question_text TEXT NOT NULL,
      answer_text TEXT NOT NULL,
      is_archive INTEGER NOT NULL
    );
  ''');
  raw.execute('''
    CREATE TABLE user_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    );
  ''');
  raw.execute('''
    CREATE TABLE user_settings_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES user_table (id),
      answer_validator_type TEXT NOT NULL DEFAULT 'ml',
      deck_generation_ai_type TEXT NOT NULL DEFAULT 'claude',
      gemini_api_key TEXT,
      gemini_model_name TEXT,
      claude_api_key TEXT,
      claude_model_name TEXT,
      open_ai_api_key TEXT,
      open_ai_model_name TEXT,
      ollama_model_url TEXT,
      ollama_model_name TEXT,
      onboarding_completed INTEGER NOT NULL DEFAULT 0
    );
  ''');
  raw.execute(
    'CREATE UNIQUE INDEX deck_table_uid ON deck_table (uid);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX quiz_card_table_uid ON quiz_card_table (uid);',
  );
  raw.execute('PRAGMA user_version = 9;');

  raw.execute(
    "INSERT INTO deck_table (id, uid, title, is_archive) "
    "VALUES (1, 1000, 'Pre-existing deck', 0);",
  );
  raw.execute(
    "INSERT INTO quiz_card_table "
    "(id, uid, deck_id, question_text, answer_text, is_archive) "
    "VALUES (1, 2000, 1, 'Q', 'A', 0);",
  );

  return NativeDatabase.opened(raw);
}

/// Seeds an in-memory sqlite3 database matching the on-disk shape of schema
/// v11 (every column/table added through v11, i.e. sync + stats columns but
/// no `parent_remote_id` on the tombstone table), then opens it with
/// [AppDatabase] so drift's real `onUpgrade` runs against it.
NativeDatabase _seedV11Database() {
  final raw = sqlite3.sqlite3.openInMemory();
  raw.execute('''
    CREATE TABLE deck_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      title TEXT NOT NULL,
      is_archive INTEGER NOT NULL,
      remote_id TEXT,
      is_dirty INTEGER NOT NULL DEFAULT 1,
      stats_accuracy_week REAL,
      stats_accuracy_month REAL,
      stats_accuracy_year REAL,
      stats_attempts_week INTEGER,
      stats_attempts_month INTEGER,
      stats_attempts_year INTEGER,
      stats_best_streak_week INTEGER,
      stats_best_streak_month INTEGER,
      stats_best_streak_year INTEGER,
      stats_last_played_at INTEGER
    );
  ''');
  raw.execute('''
    CREATE TABLE quiz_card_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      deck_id INTEGER NOT NULL REFERENCES deck_table (id),
      question_text TEXT NOT NULL,
      answer_text TEXT NOT NULL,
      is_archive INTEGER NOT NULL,
      remote_id TEXT,
      is_dirty INTEGER NOT NULL DEFAULT 1,
      stats_accuracy_week REAL,
      stats_accuracy_month REAL,
      stats_accuracy_year REAL,
      stats_attempts_week INTEGER,
      stats_attempts_month INTEGER,
      stats_attempts_year INTEGER,
      stats_best_streak_week INTEGER,
      stats_best_streak_month INTEGER,
      stats_best_streak_year INTEGER,
      stats_last_played_at INTEGER
    );
  ''');
  raw.execute('''
    CREATE TABLE user_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    );
  ''');
  raw.execute('''
    CREATE TABLE user_settings_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES user_table (id),
      answer_validator_type TEXT NOT NULL DEFAULT 'ml',
      deck_generation_ai_type TEXT NOT NULL DEFAULT 'claude',
      gemini_api_key TEXT,
      gemini_model_name TEXT,
      claude_api_key TEXT,
      claude_model_name TEXT,
      open_ai_api_key TEXT,
      open_ai_model_name TEXT,
      ollama_model_url TEXT,
      ollama_model_name TEXT,
      onboarding_completed INTEGER NOT NULL DEFAULT 0
    );
  ''');
  raw.execute('''
    CREATE TABLE sync_tombstone_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL,
      remote_id TEXT NOT NULL,
      created_at INTEGER NOT NULL
    );
  ''');
  raw.execute(
    'CREATE UNIQUE INDEX deck_table_uid ON deck_table (uid);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX quiz_card_table_uid ON quiz_card_table (uid);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX deck_table_remote_id ON deck_table (remote_id);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX quiz_card_table_remote_id '
    'ON quiz_card_table (remote_id);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX sync_tombstone_entity_remote_id '
    'ON sync_tombstone_table (entity_type, remote_id);',
  );
  raw.execute('PRAGMA user_version = 11;');

  raw.execute(
    "INSERT INTO deck_table (id, uid, title, is_archive, remote_id, is_dirty) "
    "VALUES (1, 1000, 'Pre-existing deck', 0, 'remote-deck-1', 0);",
  );
  raw.execute(
    "INSERT INTO quiz_card_table "
    "(id, uid, deck_id, question_text, answer_text, is_archive, remote_id, is_dirty) "
    "VALUES (1, 2000, 1, 'Q', 'A', 0, 'remote-card-1', 0);",
  );
  raw.execute(
    "INSERT INTO sync_tombstone_table (entity_type, remote_id, created_at) "
    "VALUES ('card', 'remote-card-2', ${DateTime.now().millisecondsSinceEpoch});",
  );

  return NativeDatabase.opened(raw);
}

/// Seeds an in-memory sqlite3 database matching the on-disk shape of schema
/// v12 (every column/table added through v12, i.e. including
/// `parent_remote_id` on the tombstone table but no `remote_updated_at` on
/// `deck_table`), then opens it with [AppDatabase] so drift's real
/// `onUpgrade` runs against it.
NativeDatabase _seedV12Database() {
  final raw = sqlite3.sqlite3.openInMemory();
  raw.execute('''
    CREATE TABLE deck_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      title TEXT NOT NULL,
      is_archive INTEGER NOT NULL,
      remote_id TEXT,
      is_dirty INTEGER NOT NULL DEFAULT 1,
      stats_accuracy_week REAL,
      stats_accuracy_month REAL,
      stats_accuracy_year REAL,
      stats_attempts_week INTEGER,
      stats_attempts_month INTEGER,
      stats_attempts_year INTEGER,
      stats_best_streak_week INTEGER,
      stats_best_streak_month INTEGER,
      stats_best_streak_year INTEGER,
      stats_last_played_at INTEGER
    );
  ''');
  raw.execute('''
    CREATE TABLE quiz_card_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      deck_id INTEGER NOT NULL REFERENCES deck_table (id),
      question_text TEXT NOT NULL,
      answer_text TEXT NOT NULL,
      is_archive INTEGER NOT NULL,
      remote_id TEXT,
      is_dirty INTEGER NOT NULL DEFAULT 1,
      stats_accuracy_week REAL,
      stats_accuracy_month REAL,
      stats_accuracy_year REAL,
      stats_attempts_week INTEGER,
      stats_attempts_month INTEGER,
      stats_attempts_year INTEGER,
      stats_best_streak_week INTEGER,
      stats_best_streak_month INTEGER,
      stats_best_streak_year INTEGER,
      stats_last_played_at INTEGER
    );
  ''');
  raw.execute('''
    CREATE TABLE user_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    );
  ''');
  raw.execute('''
    CREATE TABLE user_settings_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES user_table (id),
      answer_validator_type TEXT NOT NULL DEFAULT 'ml',
      deck_generation_ai_type TEXT NOT NULL DEFAULT 'claude',
      gemini_api_key TEXT,
      gemini_model_name TEXT,
      claude_api_key TEXT,
      claude_model_name TEXT,
      open_ai_api_key TEXT,
      open_ai_model_name TEXT,
      ollama_model_url TEXT,
      ollama_model_name TEXT,
      onboarding_completed INTEGER NOT NULL DEFAULT 0
    );
  ''');
  raw.execute('''
    CREATE TABLE sync_tombstone_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL,
      remote_id TEXT NOT NULL,
      parent_remote_id TEXT,
      created_at INTEGER NOT NULL
    );
  ''');
  raw.execute(
    'CREATE UNIQUE INDEX deck_table_uid ON deck_table (uid);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX quiz_card_table_uid ON quiz_card_table (uid);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX deck_table_remote_id ON deck_table (remote_id);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX quiz_card_table_remote_id '
    'ON quiz_card_table (remote_id);',
  );
  raw.execute(
    'CREATE UNIQUE INDEX sync_tombstone_entity_remote_id '
    'ON sync_tombstone_table (entity_type, remote_id);',
  );
  raw.execute('PRAGMA user_version = 12;');

  raw.execute(
    "INSERT INTO deck_table (id, uid, title, is_archive, remote_id, is_dirty) "
    "VALUES (1, 1000, 'Pre-existing deck', 0, 'remote-deck-1', 0);",
  );

  return NativeDatabase.opened(raw);
}

void main() {
  test('v9 -> v10 migration adds remoteId/isDirty and the tombstone table',
      () async {
    final db = AppDatabase.withExecutor(_seedV9Database());
    addTearDown(db.close);

    // Touching the database forces drift to run onUpgrade before the query.
    final decks = await db.select(db.deckTable).get();
    final cards = await db.select(db.quizCardTable).get();

    expect(decks, hasLength(1));
    expect(decks.single.remoteId, isNull);
    // Pre-existing rows are backfilled dirty so the first push cycle picks
    // them up.
    expect(decks.single.isDirty, isTrue);

    expect(cards, hasLength(1));
    expect(cards.single.remoteId, isNull);
    expect(cards.single.isDirty, isTrue);

    // The tombstone table exists and is queryable/empty.
    final tombstones = await db.select(db.syncTombstoneTable).get();
    expect(tombstones, isEmpty);

    // remoteId is unique-indexed but allows multiple NULLs (both seeded rows
    // above have a null remoteId already; this just re-confirms a second
    // NULL insert doesn't violate the index).
    await db.into(db.deckTable).insert(
          DeckTableCompanion.insert(title: 'Another deck', isArchive: false),
        );
    final allDecks = await db.select(db.deckTable).get();
    expect(allDecks, hasLength(2));
  });

  test('v11 -> v12 migration adds parentRemoteId to the tombstone table',
      () async {
    final db = AppDatabase.withExecutor(_seedV11Database());
    addTearDown(db.close);

    final tombstones = await db.select(db.syncTombstoneTable).get();
    expect(tombstones, hasLength(1));
    // Pre-existing tombstone rows backfill to null; only newly-recorded
    // deletes populate it going forward.
    expect(tombstones.single.parentRemoteId, isNull);

    // The new column is queryable/writable post-migration.
    await db.into(db.syncTombstoneTable).insert(
          SyncTombstoneTableCompanion.insert(
            entityType: 'card',
            remoteId: 'remote-card-3',
            parentRemoteId: const Value('remote-deck-1'),
            createdAt: Value(DateTime.now()),
          ),
        );
    final updated = await (db.select(db.syncTombstoneTable)
          ..where((t) => t.remoteId.isValue('remote-card-3')))
        .getSingle();
    expect(updated.parentRemoteId, 'remote-deck-1');
  });

  test('v12 -> v13 migration adds remoteUpdatedAt to deck_table', () async {
    final db = AppDatabase.withExecutor(_seedV12Database());
    addTearDown(db.close);

    final decks = await db.select(db.deckTable).get();
    expect(decks, hasLength(1));
    // Pre-existing rows backfill to null; only a successful card pull
    // populates it going forward.
    expect(decks.single.remoteUpdatedAt, isNull);

    // The new column is queryable/writable post-migration. Drift persists
    // DateTime at second precision, so compare truncated to seconds.
    final now = DateTime.fromMillisecondsSinceEpoch(
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000);
    await (db.update(db.deckTable)..where((t) => t.id.isValue(1))).write(
      DeckTableCompanion(remoteUpdatedAt: Value(now)),
    );
    final updated = await (db.select(db.deckTable)
          ..where((t) => t.id.isValue(1)))
        .getSingle();
    expect(updated.remoteUpdatedAt, now);
  });
}
