import 'package:drift/drift.dart';

/// Local outbox for analytics events awaiting upload to
/// `POST /api/analytics/events`. [id] is the client-generated UUID sent as
/// the event's dedup key, so it doubles as the primary key here. Rows are
/// deleted once the backend accepts the batch (or the batch is rejected with
/// a 400, which is dropped rather than retried — see [RemoteAnalyticsService]).
class AnalyticsEventTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// Device time (UTC), sent to the backend as-is.
  DateTimeColumn get timestamp => dateTime()();

  /// JSON-encoded event properties, or null.
  TextColumn get propertiesJson => text().nullable()();

  /// Local enqueue time, used only to order the outbox — never sent.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
