import 'package:flutter/cupertino.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class QuizEngine {
  QuizEngine({
    required this.cards,
    required this.quizService,
    required this.onTestNewCard,
  });

  final _logger = Logger.withTag('QuizEngine');
  final List<QuizCardItem> cards;
  final QuizService quizService;
  final ValueChanged<QuizCardItem> onTestNewCard;

  int _currentCardIndex = 0;

  bool get hasNext => _currentCardIndex < cards.length;

  void nextCard() {
    if (_currentCardIndex >= cards.length) {
      _logger.e('Attempted to get next card when no cards remain');
      throw Exception('Overflow');
    }
    _logger.d('Displaying card ${_currentCardIndex + 1}/${cards.length}');
    onTestNewCard.call(cards[_currentCardIndex++]);
  }

  Future<AnswerResult> checkPossibleAnswer(
    QuizCardItem quizCard,
    String possibleAnswer,
  ) {
    _logger.d('Validating answer for card ${quizCard.id}');
    return quizService.isSimilarEnough(
      question: quizCard.questionText,
      initialText: quizCard.answerText,
      inputText: possibleAnswer,
    );
  }
}
