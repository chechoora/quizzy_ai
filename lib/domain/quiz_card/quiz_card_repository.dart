import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_database_mapper.dart';

class QuizCardRepository {
  QuizCardRepository({
    required this.dataBaseRepository,
    required this.dataBaseMapper,
  });

  final QuizCardDataBaseRepository dataBaseRepository;
  final QuizCardDataBaseMapper dataBaseMapper;

  Future<List<QuizCardItem>> fetchQuizCardItem(int deckId) async {
    final databaseData = await dataBaseRepository.fetchQuizCardList(deckId);
    return dataBaseMapper.mapToQuizCardItemList(databaseData);
  }

  /// Emits on any change to any card (used to trigger iCloud auto-backup).
  Stream<List<QuizCardItem>> watchCards() {
    return dataBaseRepository
        .watchAllCards()
        .map(dataBaseMapper.mapToQuizCardItemList);
  }

  Future<int> saveQuizCard({
    required String question,
    required String answer,
    required int deckId,
  }) {
    return dataBaseRepository.saveQuizCard(
      question: question.trim(),
      answer: answer.trim(),
      deckId: deckId,
    );
  }

  Future<bool> deleteQuizCard(QuizCardItem quizCard) {
    return dataBaseRepository.deleteQuizCard(quizCard.id);
  }

  Future<bool> editQuizCard({
    required QuizCardItem currentCard,
    required QuizCardRequestItem request,
  }) {
    return dataBaseRepository.editQuizCard(
      currentCard: currentCard,
      request: request,
    );
  }

  Future<List<int>> saveQuizCards(List<PlainCardModel> cards, int deckId) {
    return dataBaseRepository.saveQuizCards(cards, deckId);
  }

  /// The set of (non-null) card uids currently stored for [deckId].
  Future<Set<int>> fetchCardUids(int deckId) {
    return dataBaseRepository.fetchCardUids(deckId);
  }

  /// Inserts cards preserving their backup uid (used by iCloud restore).
  Future<List<int>> saveCardsWithUid(List<PlainCardModel> cards, int deckId) {
    return dataBaseRepository.saveCardsWithUid(cards, deckId);
  }

  /// Updates the text of the card identified by its backup uid (restore).
  Future<bool> updateCardByUid(int deckId, PlainCardModel card) {
    return dataBaseRepository.updateCardByUid(deckId, card);
  }
}
