import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_database_mapper.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

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

  /// Emits on any change to the cards of [deckId], for the card list screen.
  Stream<List<QuizCardItem>> watchQuizCardList(int deckId) {
    return dataBaseRepository
        .watchQuizCardList(deckId)
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

  /// Local cards with unpushed changes, for the sync push cycle.
  Future<List<QuizCardItem>> fetchDirtyCards() async {
    final databaseData = await dataBaseRepository.fetchDirtyCards();
    return dataBaseMapper.mapToQuizCardItemList(databaseData);
  }

  /// Local cards in [deckId] already linked to a remote card.
  Future<List<QuizCardItem>> fetchSyncedCardsForDeck(int deckId) async {
    final databaseData =
        await dataBaseRepository.fetchSyncedCardsForDeck(deckId);
    return dataBaseMapper.mapToQuizCardItemList(databaseData);
  }

  /// Emits the count of local cards with unpushed changes, for the sync
  /// trigger. See [DeckRepository.watchDirtyDeckCount] for why this (rather
  /// than [watchCards]) is what breaks the sync feedback loop.
  Stream<int> watchDirtyCardCount() {
    return dataBaseRepository.watchDirtyCardCount();
  }

  /// Marks a local card as pushed: links it to [remoteId] and clears dirty.
  Future<void> markCardSynced(int id, String remoteId) {
    return dataBaseRepository.markCardSynced(id, remoteId);
  }

  /// Upserts a local card by [remoteId] (pull-side, remote wins). Returns
  /// the local row id.
  Future<int> upsertCardFromRemote({
    required String remoteId,
    required int deckId,
    required String question,
    required String answer,
    required bool isArchive,
    ItemStats? stats,
  }) {
    return dataBaseRepository.upsertCardByRemoteId(
      remoteId: remoteId,
      deckId: deckId,
      question: question,
      answer: answer,
      isArchive: isArchive,
      stats: stats,
    );
  }

  /// Deletes the local card linked to [remoteId], if any (pull-side
  /// reconciliation of a remote-side deletion).
  Future<bool> deleteCardByRemoteId(
    String remoteId, {
    bool recordTombstone = false,
  }) async {
    final localId = await dataBaseRepository.findCardIdByRemoteId(remoteId);
    if (localId == null) return false;
    return dataBaseRepository.deleteQuizCard(
      localId,
      recordTombstone: recordTombstone,
    );
  }
}
