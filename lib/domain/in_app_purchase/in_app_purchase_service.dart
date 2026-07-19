import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';

class InAppPurchaseService {
  final RevenueCatPurchaseManager revenueCatPurchaseManager;
  final bool isSubscriptionOnly;

  InAppPurchaseService({
    required this.revenueCatPurchaseManager,
    required this.isSubscriptionOnly,
  });

  Future<bool> isFeaturePurchased(InAppPurchaseFeature feature) async {
    if (isSubscriptionOnly) {
      return revenueCatPurchaseManager
          .isFeaturePurchased(InAppPurchaseFeature.quizzyAi.toRevenueCatId());
    }
    return revenueCatPurchaseManager.purchaseOffering(
        InAppPurchaseFeature.unlimitedDecksCards.toRevenueCatId());
  }

  // Purchase a product
  Future<bool> purchaseFeature(InAppPurchaseFeature feature) async {
    if (isSubscriptionOnly) {
      return revenueCatPurchaseManager
          .purchaseOffering(InAppPurchaseFeature.quizzyAi.toRevenueCatId());
    } else {
      return revenueCatPurchaseManager.purchaseOffering(
          InAppPurchaseFeature.unlimitedDecksCards.toRevenueCatId());
    }
  }

  // Restore previous purchases
  Future<void> restorePurchasedFeatures() async {
    return revenueCatPurchaseManager.restorePurchases();
  }

  Future<String> getAppUserId() async {
    return revenueCatPurchaseManager.getAppUserId();
  }
}

enum InAppPurchaseFeature {
  // Quizzy AI
  unlimitedDecksCards,
  // Quizzy AI PRO subscription
  quizzyAi;
}

extension on InAppPurchaseFeature {
  String toRevenueCatId() {
    switch (this) {
      case InAppPurchaseFeature.unlimitedDecksCards:
        return RevenueCatPurchaseManager.cardsAndDecksOffering;
      case InAppPurchaseFeature.quizzyAi:
        return RevenueCatPurchaseManager.quizzyAiOffering;
    }
  }
}
