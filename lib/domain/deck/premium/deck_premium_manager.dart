import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';

class DeckPremiumManager {
  final DeckRepository deckRepository;
  final InAppPurchaseService inAppPurchaseService;
  final RemoteConfigService remoteConfigService;
  final bool isSubscriptionOnly;

  DeckPremiumManager({
    required this.deckRepository,
    required this.inAppPurchaseService,
    required this.remoteConfigService,
    required this.isSubscriptionOnly,
  });

  Future<bool> canAddDeck() async {
    final allDecks = await deckRepository.fetchDecks();
    final isFeaturePurchased = isSubscriptionOnly ||
        await inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return isFeaturePurchased || allDecks.length < remoteConfigService.deckLimit;
  }
}
