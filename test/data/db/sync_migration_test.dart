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
}
