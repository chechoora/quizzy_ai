import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/model/quiz_results.dart';

class QuizMatchBuilder {
  final quizMatch = <QuizAnswerMatch>{};

  void saveResult(QuizCardItem quizCardItem, String yourAnswer, double result) {
    quizMatch.add(QuizAnswerMatch(
      cardId: quizCardItem.id,
      question: quizCardItem.questionText,
      correctAnswer: quizCardItem.answerText,
      yourAnswer: yourAnswer,
      ratio: result,
    ));
  }

  QuizResults getResults() {
    return QuizResults(
      quizMatchList: quizMatch.toList(),
    );
  }
}
