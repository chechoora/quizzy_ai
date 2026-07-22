import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Package> _mockOfferingPackages(String offeringIdentifier) {
  final context = PresentedOfferingContext(offeringIdentifier, null, null);
  return [
    Package(
      'mock_monthly',
      PackageType.monthly,
      const StoreProduct(
        'mock_monthly_product',
        'Mock monthly subscription',
        'Mock Monthly',
        4.99,
        r'$4.99',
        'USD',
      ),
      context,
    ),
    Package(
      'mock_annual',
      PackageType.annual,
      const StoreProduct(
        'mock_annual_product',
        'Mock annual subscription',
        'Mock Yearly',
        39.99,
        r'$39.99',
        'USD',
      ),
      context,
    ),
  ];
}

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
  Future<List<Package>> getOfferingPackages(String offeringIdentifier) async {
    return _mockOfferingPackages(offeringIdentifier);
  }

  @override
  Future<bool> purchaseOffering(
    String offeringIdentifier,
    String entitlementIdentifier, {
    String? packageIdentifier,
  }) async {
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

  @override
  Future<void> logIn(String appUserId) async {}

  @override
  Future<void> logOut() async {}
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
  Future<List<Package>> getOfferingPackages(String offeringIdentifier) async {
    return _mockOfferingPackages(offeringIdentifier);
  }

  @override
  Future<bool> purchaseOffering(
    String offeringIdentifier,
    String entitlementIdentifier, {
    String? packageIdentifier,
  }) async {
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

  @override
  Future<void> logIn(String appUserId) async {}

  @override
  Future<void> logOut() async {}
}
