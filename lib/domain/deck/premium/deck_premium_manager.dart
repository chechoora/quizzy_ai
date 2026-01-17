import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase_service/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class DeckPremiumManager {
  final DeckRepository deckRepository;
  final InAppPurchaseService inAppPurchaseService;

  DeckPremiumManager({
    required this.deckRepository,
    required this.inAppPurchaseService,
  });

  Future<List<DeckItemWithPremium>> fetchAllowedDecks() async {
    final allDecks = await deckRepository.fetchDecks();
    int count = 0;
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return allDecks.map((deck) {
      return DeckItemWithPremium.fromDeck(
        deckItem: deck,
        isLocked: !isFeaturePurchased && ++count < PremiumLimitInfo.deckLimit,
      );
    }).toList();
  }

  Future<bool> canAddDeck() async {
    final allDecks = await deckRepository.fetchDecks();
    final isFeaturePurchased = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    return isFeaturePurchased
        ? true
        : allDecks.length < PremiumLimitInfo.deckLimit;
  }
}
