import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/util/env_hide.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatPurchaseManager {
  // Offering for the quizzy (non-pro) flavor.
  static const cardsAndDecksOffering = 'unlimited_cards_decks';
  // Entitlement granted by cardsAndDecksOffering (configured in the
  // RevenueCat dashboard — happens to match the offering identifier).
  static const cardsAndDecksEntitlement = 'unlimited_cards_decks';
  // Offering for the quizzypro flavor.
  static const quizzyAiOffering = 'default';
  // Entitlement granted by quizzyAiOffering (configured in the RevenueCat
  // dashboard — does NOT match the offering identifier, do not assume it does).
  static const quizzyAiEntitlement = 'Quizzy AI Pro Pro';

  final Logger _logger;
  final Flavor _flavor;

  RevenueCatPurchaseManager(this._logger, this._flavor);

  Future<void> initialize() async {
    _logger.d('Initializing RevenueCat for flavor: $_flavor');
    await Purchases.setLogLevel(LogLevel.debug);

    final isPro = _flavor == Flavor.quizzyPro;
    PurchasesConfiguration configuration;
    if (kDebugMode) {
      _logger.d('Configuring with debug test key');
      configuration = PurchasesConfiguration(
        isPro ? RevenueCat.testApiKeyPro : RevenueCat.testApiKey,
      );
    } else if (Platform.isAndroid) {
      _logger.d('Configuring for Android');
      configuration = PurchasesConfiguration(
        isPro ? RevenueCat.androidApiKeyPro : RevenueCat.androidApiKey,
      );
    } else if (Platform.isIOS) {
      _logger.d('Configuring for iOS');
      configuration = PurchasesConfiguration(
        isPro ? RevenueCat.iOSApiKeyPro : RevenueCat.iOSApiKey,
      );
    } else {
      _logger.e('Unsupported platform');
      throw UnsupportedError('Unsupported platform for RevenueCat');
    }
    await Purchases.configure(configuration);
    _logger.i('RevenueCat initialized');
  }

  Future<bool> isFeaturePurchased(String entitlementIdentifier) async {
    _logger.d('Checking if feature purchased: $entitlementIdentifier');
    final customerInfo = await Purchases.getCustomerInfo();
    final isActive =
        customerInfo.entitlements.all[entitlementIdentifier]?.isActive ??
            false;
    _logger.d('Feature $entitlementIdentifier is active: $isActive');
    return isActive;
  }

  Future<List<Package>> getOfferingPackages(String offeringIdentifier) async {
    _logger.d('Fetching packages for offering: $offeringIdentifier');
    final offerings = await Purchases.getOfferings();
    final offering = offerings.all[offeringIdentifier];
    if (offering == null) {
      _logger.e('No current offering available');
      throw Exception('No current offering available');
    }
    _logger.d(
        'Found ${offering.availablePackages.length} packages for offering $offeringIdentifier');
    return offering.availablePackages;
  }

  Future<bool> purchaseOffering(
    String offeringIdentifier,
    String entitlementIdentifier, {
    String? packageIdentifier,
  }) async {
    _logger.d('Purchasing offering: $offeringIdentifier, package: '
        '${packageIdentifier ?? '(default)'}');
    final offerings = await Purchases.getOfferings();
    final offering = offerings.all[offeringIdentifier];
    if (offering == null) {
      _logger.e('No current offering available');
      throw Exception('No current offering available');
    }

    final package = packageIdentifier != null
        ? offering.availablePackages
            .firstWhereOrNull((p) => p.identifier == packageIdentifier)
        : offering.availablePackages.firstOrNull;
    if (package == null) {
      _logger.e('No available packages for offering $offeringIdentifier');
      throw Exception(
          'No available packages for offering $offeringIdentifier');
    }
    final purchaseParams = PurchaseParams.package(package);
    final result = await Purchases.purchase(purchaseParams);
    final isActive =
        result.customerInfo.entitlements.all[entitlementIdentifier]
                ?.isActive ??
            false;
    _logger
        .i('Purchase completed for $entitlementIdentifier, active: $isActive');
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
