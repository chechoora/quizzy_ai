import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  Future<bool> purchaseFeature(
    InAppPurchaseFeature feature, {
    String? packageIdentifier,
  }) async {
    if (isSubscriptionOnly) {
      return revenueCatPurchaseManager.purchaseOffering(
        InAppPurchaseFeature.quizzyAi.toOfferingId(),
        InAppPurchaseFeature.quizzyAi.toEntitlementId(),
        packageIdentifier: packageIdentifier,
      );
    } else {
      return revenueCatPurchaseManager.purchaseOffering(
        InAppPurchaseFeature.unlimitedDecksCards.toOfferingId(),
        InAppPurchaseFeature.unlimitedDecksCards.toEntitlementId(),
        packageIdentifier: packageIdentifier,
      );
    }
  }

  Future<List<PurchaseOption>> getPurchaseOptions(
    InAppPurchaseFeature feature,
  ) async {
    final packages = await revenueCatPurchaseManager
        .getOfferingPackages(feature.toOfferingId());
    final options = packages
        .map((package) => PurchaseOption(
              packageIdentifier: package.identifier,
              period: switch (package.packageType) {
                PackageType.monthly => SubscriptionPeriod.monthly,
                PackageType.annual => SubscriptionPeriod.yearly,
                _ => SubscriptionPeriod.other,
              },
              priceString: package.storeProduct.priceString,
            ))
        .toList()
      ..sort((a, b) => a.period.index.compareTo(b.period.index));
    return options;
  }

  // Restore previous purchases
  Future<void> restorePurchasedFeatures() async {
    return revenueCatPurchaseManager.restorePurchases();
  }

  Future<String> getAppUserId() async {
    return revenueCatPurchaseManager.getAppUserId();
  }

  Future<void> logInUser(String firebaseUid) {
    return revenueCatPurchaseManager.logIn(firebaseUid);
  }

  Future<void> logOutUser() {
    return revenueCatPurchaseManager.logOut();
  }

  Future<String> getManagementUrl() {
    return revenueCatPurchaseManager.getManagementUrl();
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
