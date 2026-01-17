import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class QuizCardPremiumManager {
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;

  QuizCardPremiumManager({
    required this.quizCardRepository,
    required this.inAppPurchaseService,
  });

  Future<List<QuizCardItemWithPremium>> fetchAllowedQuizCard(
      DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem);
    int count = 0;
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return allQuizCards.map((quizCard) {
      return QuizCardItemWithPremium.fromQuizCard(
        quizCardItem: quizCard,
        isLocked:
            !isFeaturePurchased && ++count < PremiumLimitInfo.quizCardLimit,
      );
    }).toList();
  }

  Future<bool> canAddQuizCard(DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem);
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return isFeaturePurchased
        ? true
        : allQuizCards.length < PremiumLimitInfo.quizCardLimit;
  }
}
