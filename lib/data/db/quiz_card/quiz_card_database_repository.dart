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

  Future<bool> saveQuizCard({
    required String question,
    required String answer,
    required int deckId,
  }) async {
    final result = await appDatabase.into(appDatabase.quizCardTable).insert(
          QuizCardTableCompanion.insert(
            deckId: deckId,
            questionText: question,
            answerText: answer,
          ),
        );
    return result != -1;
  }

  Future<bool> deleteQuizCard(int id) async {
    final result = await (appDatabase.delete(appDatabase.quizCardTable)
          ..where(
            (table) => table.id.isValue(
              id,
            ),
          ))
        .go();
    return result >= 0;
  }
}
