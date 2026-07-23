import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';

class DeckRepository {
  DeckRepository({
    required this.dataBaseRepository,
    required this.deckDatBaseMapper,
  });

  final DeckDataBaseRepository dataBaseRepository;
  final DeckDatBaseMapper deckDatBaseMapper;

  Stream<List<DeckItem>> watchDecks() {
    return dataBaseRepository
        .watchAllDecks()
        .map(deckDatBaseMapper.mapToDeckItemList);
  }

  Future<List<DeckItem>> fetchDecks() async {
    final databaseData = await dataBaseRepository.fetchAllDecks();
    return deckDatBaseMapper.mapToDeckItemList(databaseData);
  }

  Future<int> saveDeck(String deckName) {
    return dataBaseRepository.saveDeck(deckName.trim());
  }

  Future<List<int>> saveDecks(List<String> deckNames) {
    return dataBaseRepository
        .saveDecks(deckNames.map((e) => e.trim()).toList());
  }

  Future<bool> deleteDeck(DeckItem deck) {
    return dataBaseRepository.deleteDeck(deck.id);
  }

  Future<bool> editDeckName(DeckItem deck, String deckName) {
    return dataBaseRepository.editDeckName(deck, deckName.trim());
  }

  /// Returns the local row id of the deck with the given backup [uid], or null.
  Future<int?> findDeckIdByUid(int uid) {
    return dataBaseRepository.findDeckIdByUid(uid);
  }

  /// Inserts a deck preserving its backup [uid] (used by iCloud restore).
  Future<int> saveDeckWithUid(String title, int uid) {
    return dataBaseRepository.saveDeckWithUid(title.trim(), uid);
  }

  /// Local decks with unpushed changes, for the sync push cycle.
  Future<List<DeckItem>> fetchDirtyDecks() async {
    final databaseData = await dataBaseRepository.fetchDirtyDecks();
    return deckDatBaseMapper.mapToDeckItemList(databaseData);
  }

  /// Local decks already linked to a remote deck.
  Future<List<DeckItem>> fetchSyncedDecks() async {
    final databaseData = await dataBaseRepository.fetchSyncedDecks();
    return deckDatBaseMapper.mapToDeckItemList(databaseData);
  }

  /// Marks a local deck as pushed: links it to [remoteId] and clears dirty.
  Future<void> markDeckSynced(int id, String remoteId) {
    return dataBaseRepository.markDeckSynced(id, remoteId);
  }

  /// Upserts a local deck by [remoteId] (pull-side, remote wins). Returns
  /// the local row id.
  Future<int> upsertDeckFromRemote({
    required String remoteId,
    required String title,
    required bool isArchive,
    ItemStats? stats,
  }) {
    return dataBaseRepository.upsertDeckByRemoteId(
      remoteId: remoteId,
      title: title,
      isArchive: isArchive,
      stats: stats,
    );
  }

  /// Deletes the local deck linked to [remoteId], if any (pull-side
  /// reconciliation of a remote-side deletion).
  Future<bool> deleteDeckByRemoteId(
    String remoteId, {
    bool recordTombstone = false,
  }) async {
    final localId = await dataBaseRepository.findDeckIdByRemoteId(remoteId);
    if (localId == null) return false;
    return dataBaseRepository.deleteDeck(
      localId,
      recordTombstone: recordTombstone,
    );
  }
}
