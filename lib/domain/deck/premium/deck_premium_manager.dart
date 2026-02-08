import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class DeckPremiumManager {
  final DeckRepository deckRepository;
  final InAppPurchaseService inAppPurchaseService;

  DeckPremiumManager({
    required this.deckRepository,
    required this.inAppPurchaseService,
  });

  Stream<List<DeckItemWithPremium>> watchAllowedDecks() {
    return deckRepository.watchDecks().asyncMap((allDecks) async {
      int count = 0;
      final isFeaturePurchased = await inAppPurchaseService
          .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
      return allDecks.map((deck) {
        return DeckItemWithPremium.fromDeck(
          deckItem: deck,
          isLocked: PremiumLimitInfo.isLocked(
            featurePurchased: isFeaturePurchased,
            count: ++count,
            limit: PremiumLimitInfo.deckLimit,
          ),
        );
      }).toList();
    });
  }

  Future<List<DeckItemWithPremium>> fetchAllowedDecks() async {
    final allDecks = await deckRepository.fetchDecks();
    int count = 0;
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return allDecks.map((deck) {
      return DeckItemWithPremium.fromDeck(
        deckItem: deck,
        isLocked: PremiumLimitInfo.isLocked(
          featurePurchased: isFeaturePurchased,
          count: ++count,
          limit: PremiumLimitInfo.deckLimit,
        ),
      );
    }).toList();
  }

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
