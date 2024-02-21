import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class DeckRepository {
  DeckRepository({
    required this.dataBaseRepository,
    required this.deckDatBaseMapper,
  });

  final DeckDataBaseRepository dataBaseRepository;
  final DeckDatBaseMapper deckDatBaseMapper;

  Future<List<DeckItem>> fetchDecks() async {
    final databaseData = await dataBaseRepository.fetchAllDecks();
    return deckDatBaseMapper.mapToDeckItemList(databaseData);
  }

  Future<bool> saveDeck(String deckName) {
    return dataBaseRepository.saveDeck(deckName);
  }
}
