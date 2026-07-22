import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCacheRevenueCatPurchaseManager implements RevenueCatPurchaseManager {
  bool _isUnlocked = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isFeaturePurchased(String entitlementIdentifier) async {
    if (entitlementIdentifier ==
        RevenueCatPurchaseManager.cardsAndDecksEntitlement) {
      return _isUnlocked;
    }
    return false;
  }

  @override
  Future<bool> purchaseOffering(
    String offeringIdentifier,
    String entitlementIdentifier,
  ) async {
    if (entitlementIdentifier ==
        RevenueCatPurchaseManager.cardsAndDecksEntitlement) {
      _isUnlocked = true;
      return true;
    }
    return false;
  }

  @override
  Future<void> restorePurchases() async {
    _isUnlocked = true;
  }

  @override
  Future<String> getAppUserId() {
    return Future.value('mock_user_id');
  }
}

class MockPrefRevenueCatPurchaseManager implements RevenueCatPurchaseManager {
  static const _prefKeyPrefix = 'mock_purchase_';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isFeaturePurchased(String entitlementIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefKeyPrefix$entitlementIdentifier') ?? false;
  }

  @override
  Future<bool> purchaseOffering(
    String offeringIdentifier,
    String entitlementIdentifier,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefKeyPrefix$entitlementIdentifier', true);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        '$_prefKeyPrefix${RevenueCatPurchaseManager.cardsAndDecksEntitlement}',
        true);
  }

  @override
  Future<String> getAppUserId() {
    return Future.value('mock_user_id');
  }
}
