import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class QuizCardPremiumManager {
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;

  QuizCardPremiumManager({
    required this.quizCardRepository,
    required this.inAppPurchaseService,
  });

  Future<bool> canAddQuizCard(DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem.id);
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return PremiumLimitInfo.canAdd(
      featurePurchased: isFeaturePurchased,
      count: allQuizCards.length,
      limit: PremiumLimitInfo.quizCardLimit,
    );
  }
}
