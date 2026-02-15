import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';

class InAppPurchaseService {
  final RevenueCatPurchaseManager revenueCatPurchaseManager;

  InAppPurchaseService({
    required this.revenueCatPurchaseManager,
  });

  Future<bool> isFeaturePurchased(InAppPurchaseFeature feature) async {
    return revenueCatPurchaseManager
        .isFeaturePurchased(feature.toRevenueCatId());
  }

  // Purchase a product
  Future<bool> purchaseFeature(InAppPurchaseFeature feature) async {
    return revenueCatPurchaseManager.purchaseOffering(feature.toRevenueCatId());
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
  unlimitedDecksCards,
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
