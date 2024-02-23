import 'package:poc_ai_quiz/data/db/database.dart';

class QuizCardDataBaseRepository {
  final AppDatabase appDatabase;

  QuizCardDataBaseRepository(this.appDatabase);

  Future<List<QuizCardTableData>> fetchQuizCardList(int deckId) {
    return (appDatabase.select(appDatabase.quizCardTable)
          ..where(
            (table) {
              return table.deckId.isValue(deckId);
            },
          ))
        .get();
  }
}
