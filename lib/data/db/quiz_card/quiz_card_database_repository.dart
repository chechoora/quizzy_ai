import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';

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

  Future<int> saveQuizCard({
    required String question,
    required String answer,
    required int deckId,
  }) async {
    final result = await appDatabase.into(appDatabase.quizCardTable).insert(
          QuizCardTableCompanion.insert(
            deckId: deckId,
            questionText: question,
            answerText: answer,
            isArchive: false,
          ),
        );
    return result;
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

  Future<bool> editQuizCard({
    required QuizCardItem currentCard,
    required QuizCardRequestItem request,
  }) async {
    final result = await (appDatabase.update(appDatabase.quizCardTable)
          ..where(
            (table) => table.id.isValue(
              currentCard.id,
            ),
          ))
        .write(
      QuizCardTableCompanion(
        questionText: Value(request.question),
        answerText: Value(request.answer),
      ),
    );
    return result >= 0;
  }

  Future<List<int>> saveQuizCards(
      List<PlainCardModel> cards, int deckId) async {
    return appDatabase.transaction(
      () async {
        final result = <int>[];
        for (final card in cards) {
          final id = await appDatabase.into(appDatabase.quizCardTable).insert(
                QuizCardTableCompanion.insert(
                  deckId: deckId,
                  questionText: card.question,
                  answerText: card.answer,
                  isArchive: false,
                ),
              );
          result.add(id);
        }
        return result;
      },
    );
  }
}
