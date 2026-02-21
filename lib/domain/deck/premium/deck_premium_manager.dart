import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class DeckPremiumManager {
  final DeckRepository deckRepository;
  final InAppPurchaseService inAppPurchaseService;

  DeckPremiumManager({
    required this.deckRepository,
    required this.inAppPurchaseService,
  });

  Future<bool> canAddDeck() async {
    final allDecks = await deckRepository.fetchDecks();
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return PremiumLimitInfo.canAdd(
      featurePurchased: isFeaturePurchased,
      count: allDecks.length,
      limit: PremiumLimitInfo.deckLimit,
    );
  }
}
