import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';

class MockRevenueCatPurchaseManager implements RevenueCatPurchaseManager {
  static const cardsAndDecksOffering = 'unlimited_cards_decks';

  bool _isUnlocked = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isFeaturePurchased(String identifier) async {
    if (identifier == cardsAndDecksOffering) {
      return _isUnlocked;
    }
    return false;
  }

  @override
  Future<bool> purchaseOffering(String identifier) async {
    if (identifier == cardsAndDecksOffering) {
      _isUnlocked = true;
      return true;
    }
    return false;
  }

  @override
  Future<void> restorePurchases() async {
    _isUnlocked = true;
  }
}
