class AppEnv {
  static const String purchaseTypeReal = 'real';
  static const String purchaseTypeMockPref = 'mock_pref';
  static const String purchaseTypeMockCache = 'mock_cache';

  /// Purchase manager type: "real", "mock_pref", "mock_cache"
  static const String purchaseType = String.fromEnvironment(
    'PURCHASE_TYPE',
    defaultValue: purchaseTypeReal,
  );
}

class RevenueCat {
  static const String iOSApiKey = 'appl_UcqMeRnRhKnfqeIYZvQqMtVUuwi';
  static const String androidApiKey = 'goog_fUfSogyNRfSknrEhbePAFPCzgrU';
}
