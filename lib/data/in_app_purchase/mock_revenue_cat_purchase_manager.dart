import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCacheRevenueCatPurchaseManager implements RevenueCatPurchaseManager {
  bool _isUnlocked = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isFeaturePurchased(String identifier) async {
    if (identifier == RevenueCatPurchaseManager.cardsAndDecksOffering) {
      return _isUnlocked;
    }
    return false;
  }

  @override
  Future<bool> purchaseOffering(String identifier) async {
    if (identifier == RevenueCatPurchaseManager.cardsAndDecksOffering) {
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
  Future<bool> isFeaturePurchased(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefKeyPrefix$identifier') ?? false;
  }

  @override
  Future<bool> purchaseOffering(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefKeyPrefix$identifier', true);
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        '$_prefKeyPrefix${RevenueCatPurchaseManager.cardsAndDecksOffering}',
        true);
  }

  @override
  Future<String> getAppUserId() {
    return Future.value('mock_user_id');
  }
}
