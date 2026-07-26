import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class DeckDatBaseMapper {
  List<DeckItem> mapToDeckItemList(List<DeckTableData> dataBaseDeckItems) {
    return dataBaseDeckItems.map(mapToDeckItem).toList();
  }

  DeckItem mapToDeckItem(DeckTableData e) {
    return DeckItem(
      id: e.id,
      uid: e.uid,
      title: e.title,
      isArchive: e.isArchive,
      remoteId: e.remoteId,
      isDirty: e.isDirty,
      remoteUpdatedAt: e.remoteUpdatedAt,
      remoteLastActivityAt: e.remoteLastActivityAt,
      stats: _mapStats(e),
    );
  }

  /// [DeckTableData.statsAttemptsWeek] is always a concrete number whenever
  /// stats were written by the sync pull path (all ten columns are written
  /// together as one unit), so its nullness doubles as the "has stats" flag.
  ItemStats? _mapStats(DeckTableData row) {
    if (row.statsAttemptsWeek == null) return null;
    return ItemStats(
      accuracy: PeriodStats(
        week: row.statsAccuracyWeek,
        month: row.statsAccuracyMonth,
        year: row.statsAccuracyYear,
      ),
      attempts: PeriodStats(
        week: row.statsAttemptsWeek ?? 0,
        month: row.statsAttemptsMonth ?? 0,
        year: row.statsAttemptsYear ?? 0,
      ),
      bestStreak: PeriodStats(
        week: row.statsBestStreakWeek ?? 0,
        month: row.statsBestStreakMonth ?? 0,
        year: row.statsBestStreakYear ?? 0,
      ),
      lastPlayedAt: row.statsLastPlayedAt,
    );
  }
}
