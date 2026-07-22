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
      return revenueCatPurchaseManager.isFeaturePurchased(
          InAppPurchaseFeature.quizzyAi.toEntitlementId());
    }
    return revenueCatPurchaseManager.isFeaturePurchased(
        InAppPurchaseFeature.unlimitedDecksCards.toEntitlementId());
  }

  // Purchase a product
  Future<bool> purchaseFeature(InAppPurchaseFeature feature) async {
    if (isSubscriptionOnly) {
      return revenueCatPurchaseManager.purchaseOffering(
        InAppPurchaseFeature.quizzyAi.toOfferingId(),
        InAppPurchaseFeature.quizzyAi.toEntitlementId(),
      );
    } else {
      return revenueCatPurchaseManager.purchaseOffering(
        InAppPurchaseFeature.unlimitedDecksCards.toOfferingId(),
        InAppPurchaseFeature.unlimitedDecksCards.toEntitlementId(),
      );
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
  // Quizzy AI\
  unlimitedDecksCards,
  // Quizzy AI PRO subscription
  quizzyAi;
}

extension on InAppPurchaseFeature {
  String toOfferingId() {
    switch (this) {
      case InAppPurchaseFeature.unlimitedDecksCards:
        return RevenueCatPurchaseManager.cardsAndDecksOffering;
      case InAppPurchaseFeature.quizzyAi:
        return RevenueCatPurchaseManager.quizzyAiOffering;
    }
  }

  String toEntitlementId() {
    switch (this) {
      case InAppPurchaseFeature.unlimitedDecksCards:
        return RevenueCatPurchaseManager.cardsAndDecksEntitlement;
      case InAppPurchaseFeature.quizzyAi:
        return RevenueCatPurchaseManager.quizzyAiEntitlement;
    }
  }
}
