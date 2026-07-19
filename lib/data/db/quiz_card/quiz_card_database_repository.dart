import 'package:drift/drift.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/util/uid_generator.dart';

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

  /// Watches all cards across every deck. Emits on any card insert/update/
  /// delete, used to trigger the iCloud auto-backup.
  Stream<List<QuizCardTableData>> watchAllCards() {
    return appDatabase.select(appDatabase.quizCardTable).watch();
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
            uid: Value(UidGenerator.next()),
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
                  uid: Value(UidGenerator.next()),
                ),
              );
          result.add(id);
        }
        return result;
      },
    );
  }

  /// The set of (non-null) card uids currently stored for [deckId].
  Future<Set<int>> fetchCardUids(int deckId) async {
    final rows = await (appDatabase.select(appDatabase.quizCardTable)
          ..where((table) => table.deckId.isValue(deckId)))
        .get();
    return rows
        .map((r) => r.uid)
        .whereType<int>()
        .toSet();
  }

  /// Inserts cards preserving their backup uid (used by iCloud restore).
  /// Falls back to a fresh uid when a card has none.
  Future<List<int>> saveCardsWithUid(
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
                  uid: Value(card.uid ?? UidGenerator.next()),
                ),
              );
          result.add(id);
        }
        return result;
      },
    );
  }

  /// Updates the text of the card identified by its backup [uid] within
  /// [deckId] (used by iCloud restore to reflect edits from another device).
  Future<bool> updateCardByUid(int deckId, PlainCardModel card) async {
    final uid = card.uid;
    if (uid == null) return false;
    final result = await (appDatabase.update(appDatabase.quizCardTable)
          ..where(
            (table) => table.deckId.isValue(deckId) & table.uid.isValue(uid),
          ))
        .write(
      QuizCardTableCompanion(
        questionText: Value(card.question),
        answerText: Value(card.answer),
      ),
    );
    return result > 0;
  }
}
