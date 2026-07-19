import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';

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
}
