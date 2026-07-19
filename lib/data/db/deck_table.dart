import 'package:drift/drift.dart';

// Uniqueness of [uid] is enforced with a unique index rather than a column-level
// UNIQUE constraint: SQLite cannot add a UNIQUE column via `ALTER TABLE ADD
// COLUMN`, so a column constraint would break the additive migration. A unique
// index works for both fresh installs and upgrades and still allows multiple
// NULLs (rows created before the uid backfill).
@TableIndex(name: 'deck_table_uid', columns: {#uid}, unique: true)
@TableIndex(name: 'deck_table_remote_id', columns: {#remoteId}, unique: true)
class DeckTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable, timestamp-based unique id used for idempotent iCloud
  /// backup/restore (dedupe across devices). Nullable for additive migration.
  IntColumn get uid => integer().nullable()();

  TextColumn get title => text().withLength(min: 3)();

  BoolColumn get isArchive => boolean()();

  /// quizzy-ai-pro backend id once this deck has been created remotely.
  /// Null means it has never been pushed. Unique index allows multiple
  /// NULLs (SQLite), which is required since most local rows start unsynced.
  TextColumn get remoteId => text().nullable()();

  /// True when this row has local changes not yet pushed to the backend.
  /// Defaults to true so every new insert (and every pre-existing row,
  /// backfilled by the v10 migration) is picked up by the next push cycle.
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'quiz_card_table_uid', columns: {#uid}, unique: true)
@TableIndex(name: 'quiz_card_table_remote_id', columns: {#remoteId}, unique: true)
class QuizCardTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable, timestamp-based unique id used for idempotent iCloud
  /// backup/restore (dedupe across devices). Nullable for additive migration.
  IntColumn get uid => integer().nullable()();

  IntColumn get deckId => integer().references(DeckTable, #id)();

  TextColumn get questionText => text().withLength(min: 1)();

  TextColumn get answerText => text().withLength(min: 1)();

  BoolColumn get isArchive => boolean()();

  /// quizzy-ai-pro backend id once this card has been created remotely.
  TextColumn get remoteId => text().nullable()();

  /// True when this row has local changes not yet pushed to the backend.
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
