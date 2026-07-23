import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class QuizCardDataBaseMapper {
  List<QuizCardItem> mapToQuizCardItemList(List<QuizCardTableData> dataBaseQuizCardItems) {
    return dataBaseQuizCardItems
        .map(
          (e) => QuizCardItem(
            id: e.id,
            uid: e.uid,
            deckId: e.deckId,
            questionText: e.questionText,
            answerText: e.answerText,
            isArchive: e.isArchive,
            remoteId: e.remoteId,
            isDirty: e.isDirty,
            stats: _mapStats(e),
          ),
        )
        .toList();
  }

  /// [QuizCardTableData.statsAttemptsWeek] is always a concrete number
  /// whenever stats were written by the sync pull path (all ten columns are
  /// written together as one unit), so its nullness doubles as the "has
  /// stats" flag.
  ItemStats? _mapStats(QuizCardTableData row) {
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
