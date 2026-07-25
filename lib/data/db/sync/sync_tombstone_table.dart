import 'package:drift/drift.dart';

/// Records a local deletion of an already-synced deck/card so the delete can
/// be propagated to the quizzy-ai-pro backend later (including after the
/// device was offline when the delete happened). Purged once the remote
/// delete succeeds (or the remote confirms the row is already gone).
@TableIndex(
  name: 'sync_tombstone_entity_remote_id',
  columns: {#entityType, #remoteId},
  unique: true,
)
class SyncTombstoneTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'deck' | 'card'.
  TextColumn get entityType => text()();

  /// The backend id to DELETE remotely.
  TextColumn get remoteId => text()();

  /// The owning deck's backend id, for `'card'` tombstones — needed to group
  /// them per deck for `DELETE /decks/{id}/cards/batch`. Always null for
  /// `'deck'` tombstones and always non-null for `'card'` tombstones (a card
  /// can only have a [remoteId] once its parent deck already has one).
  TextColumn get parentRemoteId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
