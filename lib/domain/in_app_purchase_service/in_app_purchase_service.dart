class InAppPurchaseService {
  Future<bool> isFeaturePurchased(InAppPurchaseFeature feature) async {
    return true;
  }

  // Purchase a product
  Future<void> purchaseFeature(InAppPurchaseFeature feature) async {}

  // Restore previous purchases
  Future<void> restorePurchasedFeatures() async {}
}

enum InAppPurchaseFeature {
  unlimitedDecksCards,
}
