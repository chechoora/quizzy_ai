import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';

class QuizCardPremiumManager {
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;
  final RemoteConfigService remoteConfigService;
  final bool isSubscriptionOnly;

  QuizCardPremiumManager({
    required this.quizCardRepository,
    required this.inAppPurchaseService,
    required this.remoteConfigService,
    required this.isSubscriptionOnly,
  });

  Future<bool> canAddQuizCard(DeckItem deckItem) async {
    final allQuizCards = await quizCardRepository.fetchQuizCardItem(deckItem.id);
    final isFeaturePurchased = isSubscriptionOnly ||
        await inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return isFeaturePurchased ||
        allQuizCards.length < remoteConfigService.quizCardLimit;
  }
}
