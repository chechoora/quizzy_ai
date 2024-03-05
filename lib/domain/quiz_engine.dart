import 'package:flutter/cupertino.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_service.dart';

class QuizEngine {
  QuizEngine({
    required this.cards,
    required this.quizService,
    required this.onTestNewCard,
  });

  final List<QuizCardItem> cards;
  final QuizService quizService;
  final ValueChanged<QuizCardItem> onTestNewCard;

  int _currentCardIndex = 0;

  bool get hasNext => _currentCardIndex < cards.length;

  void nextCard() {
    if (_currentCardIndex >= cards.length) {
      throw Exception('Overflow');
    }
    if (_currentCardIndex == 0) {
      onTestNewCard.call(cards[_currentCardIndex]);
    } else {
      _currentCardIndex++;
      onTestNewCard.call(cards[_currentCardIndex]);
    }
  }

  Future<double> checkPossibleAnswer(
    QuizCardItem quizCard,
    String possibleAnswer,
  ) {
    return quizService.isSimilarEnough(
      initialText: quizCard.answerText,
      inputText: possibleAnswer,
    );
  }
}
