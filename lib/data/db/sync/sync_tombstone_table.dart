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

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
