import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Seeds an in-memory sqlite3 database matching the on-disk shape of schema
/// v10 (i.e. every column added by migrations up to and including v10, none
/// of the v11 stats columns), then opens it with [AppDatabase] so drift's
/// real `onUpgrade` runs against it — exercising the same code path a real
/// device upgrade takes.
NativeDatabase _seedV10Database() {
  final raw = sqlite3.sqlite3.openInMemory();
  raw.execute('''
    CREATE TABLE deck_table (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      uid INTEGER,
      title TEXT NOT NULL,
      is_archive INTEGER NOT NULL,
      remote_id TEXT,
      is_dirty INTEGER NOT NULL DEFAULT 1
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
      is_dirty INTEGER NOT NULL DEFAULT 1
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
    'CREATE UNIQUE INDEX quiz_card_table_remote_id ON quiz_card_table (remote_id);',
  );
  raw.execute('PRAGMA user_version = 10;');

  raw.execute(
    "INSERT INTO deck_table (id, uid, title, is_archive, remote_id, is_dirty) "
    "VALUES (1, 1000, 'Pre-existing deck', 0, 'rd1', 0);",
  );
  raw.execute(
    "INSERT INTO quiz_card_table "
    "(id, uid, deck_id, question_text, answer_text, is_archive, remote_id, is_dirty) "
    "VALUES (1, 2000, 1, 'Q', 'A', 0, 'rc1', 0);",
  );

  return NativeDatabase.opened(raw);
}

void main() {
  test('v10 -> v11 migration adds stats columns, read back as null',
      () async {
    final db = AppDatabase.withExecutor(_seedV10Database());
    addTearDown(db.close);

    // Touching the database forces drift to run onUpgrade before the query.
    final decks = await db.select(db.deckTable).get();
    final cards = await db.select(db.quizCardTable).get();

    expect(decks, hasLength(1));
    final deck = decks.single;
    expect(deck.statsAccuracyWeek, isNull);
    expect(deck.statsAccuracyMonth, isNull);
    expect(deck.statsAccuracyYear, isNull);
    expect(deck.statsAttemptsWeek, isNull);
    expect(deck.statsAttemptsMonth, isNull);
    expect(deck.statsAttemptsYear, isNull);
    expect(deck.statsBestStreakWeek, isNull);
    expect(deck.statsBestStreakMonth, isNull);
    expect(deck.statsBestStreakYear, isNull);
    expect(deck.statsLastPlayedAt, isNull);

    expect(cards, hasLength(1));
    final card = cards.single;
    expect(card.statsAccuracyWeek, isNull);
    expect(card.statsAttemptsWeek, isNull);
    expect(card.statsBestStreakWeek, isNull);
    expect(card.statsLastPlayedAt, isNull);

    // The new columns are writable/queryable post-migration.
    await (db.update(db.deckTable)..where((t) => t.id.isValue(1))).write(
      DeckTableCompanion(
        statsAttemptsWeek: const Value(3),
        statsAccuracyWeek: const Value(0.75),
        statsLastPlayedAt: Value(DateTime(2026, 1, 1)),
      ),
    );
    final updated =
        await (db.select(db.deckTable)..where((t) => t.id.isValue(1)))
            .getSingle();
    expect(updated.statsAttemptsWeek, 3);
    expect(updated.statsAccuracyWeek, 0.75);
    expect(updated.statsLastPlayedAt, DateTime(2026, 1, 1));
  });
}
