import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';

/// Plain CRUD access to the local analytics outbox ([AnalyticsEventTable]).
/// [RemoteAnalyticsService] is the only caller: it enqueues on [track] and
/// drains the queue in FIFO order on each flush.
class AnalyticsEventDataBaseRepository {
  AnalyticsEventDataBaseRepository(this.appDatabase);

  final AppDatabase appDatabase;

  Future<void> enqueue({
    required String id,
    required String name,
    required DateTime timestamp,
    String? propertiesJson,
  }) async {
    await appDatabase.into(appDatabase.analyticsEventTable).insert(
          AnalyticsEventTableCompanion.insert(
            id: id,
            name: name,
            timestamp: timestamp,
            propertiesJson: Value(propertiesJson),
          ),
        );
  }

  /// Up to [limit] oldest-enqueued events still pending upload.
  Future<List<AnalyticsEventTableData>> peekBatch(int limit) {
    return (appDatabase.select(appDatabase.analyticsEventTable)
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await (appDatabase.delete(appDatabase.analyticsEventTable)
          ..where((table) => table.id.isIn(ids)))
        .go();
  }
}
