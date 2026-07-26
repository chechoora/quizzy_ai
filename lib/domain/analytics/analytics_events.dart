/// Canonical analytics event names. Keep every `AnalyticsService.track(...)`
/// call site referencing a name from here so event names can't drift or typo
/// across call sites.
abstract final class AnalyticsEvents {
  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String purchaseCompleted = 'purchase_completed';
  static const String quizStarted = 'quiz_started';
  static const String quizCompleted = 'quiz_completed';
  static const String quizLeft = 'quiz_left';
}

/// Property keys reused across multiple events.
abstract final class AnalyticsProperties {
  static const String screenName = 'screen_name';
  static const String provider = 'provider';
  static const String feature = 'feature';
  static const String packageIdentifier = 'package_identifier';
  static const String price = 'price';
  static const String period = 'period';
  static const String cardCount = 'card_count';
  static const String isQuickPlay = 'is_quick_play';
  static const String correctCount = 'correct_count';
}
