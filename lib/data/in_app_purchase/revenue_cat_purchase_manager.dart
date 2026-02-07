import 'dart:io';

import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/env_hide.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatPurchaseManager {
  static const cardsAndDecksOffering = 'unlimited_cards_decks';
  static const quizzyAiOffering = 'quizzy_ai';

  final Logger _logger;

  RevenueCatPurchaseManager(this._logger);

  Future<void> initialize() async {
    _logger.d('Initializing RevenueCat');
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      _logger.d('Configuring for Android');
      configuration = PurchasesConfiguration(RevenueCat.androidApiKey);
    } else if (Platform.isIOS) {
      _logger.d('Configuring for iOS');
      configuration = PurchasesConfiguration(RevenueCat.iOSApiKey);
    } else {
      _logger.e('Unsupported platform');
      throw UnsupportedError('Unsupported platform for RevenueCat');
    }
    await Purchases.configure(configuration);
    _logger.i('RevenueCat initialized');
  }

  Future<bool> isFeaturePurchased(String identifier) async {
    _logger.d('Checking if feature purchased: $identifier');
    final customerInfo = await Purchases.getCustomerInfo();
    final isActive =
        customerInfo.entitlements.all[identifier]?.isActive ?? false;
    _logger.d('Feature $identifier is active: $isActive');
    return isActive;
  }

  Future<bool> purchaseOffering(String identifier) async {
    _logger.d('Purchasing offering: $identifier');
    final offerings = await Purchases.getOfferings();
    final offering = offerings.all[identifier];
    if (offering == null) {
      _logger.e('No current offering available');
      throw Exception('No current offering available');
    }

    final package = offering.availablePackages.firstOrNull;
    if (package == null) {
      _logger.e('No available packages for offering $identifier');
      throw Exception('No available packages for offering $identifier');
    }
    final purchaseParams = PurchaseParams.package(package);
    final result = await Purchases.purchase(purchaseParams);
    final isActive =
        result.customerInfo.entitlements.all[identifier]?.isActive ?? false;
    _logger.i('Purchase completed for $identifier, active: $isActive');
    return isActive;
  }

  Future<void> restorePurchases() async {
    _logger.d('Restoring purchases');
    await Purchases.restorePurchases();
    _logger.i('Purchases restored');
  }

  Future<String> getAppUserId() async {
    return (await Purchases.getCustomerInfo()).originalAppUserId;
  }
}
