import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class QuizCardDataBaseMapper {
  List<QuizCardItem> mapToQuizCardItemList(List<QuizCardTableData> dataBaseQuizCardItems) {
    return dataBaseQuizCardItems
        .map(
          (e) => QuizCardItem(
            e.id,
            e.deckId,
            e.questionText,
            e.answerText,
          ),
        )
        .toList();
  }
}
