import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class QuizCardPremiumManager {
  final UserRepository userRepository;
  final QuizCardRepository quizCardRepository;

  QuizCardPremiumManager({
    required this.userRepository,
    required this.quizCardRepository,
  });

  Future<List<QuizCardItemWithPremium>> fetchAllowedQuizCard(DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem);
    final user = await userRepository.fetchCurrentUser();
    int count = 0;
    return allQuizCards.map((quizCard) {
      return QuizCardItemWithPremium.fromQuizCard(
        quizCardItem: quizCard,
        isLocked: !user.isPremium && ++count < PremiumLimitInfo.quizCardLimit,
      );
    }).toList();
  }

  Future<bool> canAddQuizCard(DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem);
    return allQuizCards.length < PremiumLimitInfo.quizCardLimit;
  }
}
