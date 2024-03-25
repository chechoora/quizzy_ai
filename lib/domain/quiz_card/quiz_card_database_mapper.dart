import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';

class QuizCardDataBaseMapper {
  List<QuizCardItem> mapToQuizCardItemList(List<QuizCardTableData> dataBaseQuizCardItems) {
    return dataBaseQuizCardItems
        .map(
          (e) => QuizCardItem(
            id: e.id,
            deckId: e.deckId,
            questionText: e.questionText,
            answerText: e.answerText,
            isArchive: e.isArchive,
          ),
        )
        .toList();
  }
}
