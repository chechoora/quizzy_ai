import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_database_mapper.dart';

class QuizCardRepository {
  QuizCardRepository({
    required this.dataBaseRepository,
    required this.dataBaseMapper,
  });

  final QuizCardDataBaseRepository dataBaseRepository;
  final QuizCardDataBaseMapper dataBaseMapper;

  Future<List<QuizCardItem>> fetchDecks(DeckItem deckItem) async {
    final databaseData = await dataBaseRepository.fetchQuizCardList(deckItem.id);
    return dataBaseMapper.mapToQuizCardItemList(databaseData);
  }
}
