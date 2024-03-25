import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
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

  Future<List<QuizCardItem>> fetchQuizCardItem(DeckItem deckItem) async {
    final databaseData = await dataBaseRepository.fetchQuizCardList(deckItem.id);
    return dataBaseMapper.mapToQuizCardItemList(databaseData);
  }

  Future<bool> saveQuizCard({
    required String question,
    required String answer,
    required int deckId,
  }) {
    return dataBaseRepository.saveQuizCard(
      question: question,
      answer: answer,
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
}
