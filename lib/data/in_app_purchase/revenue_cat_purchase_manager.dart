import 'dart:io';

import 'package:poc_ai_quiz/util/env.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatPurchaseManager {
  static const cardsAndDecksOffering = 'Unlimited Cards & Decks';

  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(RevenueCat.androidApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(RevenueCat.iOSApiKey);
    } else {
      throw UnsupportedError('Unsupported platform for RevenueCat');
    }
    await Purchases.configure(configuration);
  }

  Future<bool> isFeaturePurchased(String identifier) async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.all[identifier]?.isActive ?? false;
  }

  Future<bool> purchaseOffering(String identifier) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;
    if (offering == null) {
      throw Exception('No current offering available');
    }

    final package = offering.availablePackages.firstWhere(
      (pkg) => pkg.identifier == identifier,
      orElse: () =>
          throw Exception('Feature $identifier not found in offerings'),
    );
    final purchaseParams = PurchaseParams.package(package);
    final result = await Purchases.purchase(purchaseParams);
    return result.customerInfo.entitlements.all[identifier]?.isActive ?? false;
  }

  Future<void> restorePurchases() async {
    await Purchases.restorePurchases();
  }
}
