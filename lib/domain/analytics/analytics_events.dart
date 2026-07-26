/// Canonical analytics event names. Keep every `AnalyticsService.track(...)`
/// call site referencing a name from here so event names can't drift or typo
/// across call sites.
abstract final class AnalyticsEvents {
  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String subscriptionStarted = 'subscription_started';
  static const String quizStarted = 'quiz_started';
  static const String quizCompleted = 'quiz_completed';
  static const String quizLeft = 'quiz_left';
  static const String appOpened = 'app_opened';
  static const String deckGenerated = 'deck_generated';
  static const String deckGenerationFailed = 'deck_generation_failed';
  static const String cardEdited = 'card_edited';
  static const String answerChecked = 'answer_checked';
  static const String paywallShown = 'paywall_shown';
  static const String publicDeckViewed = 'public_deck_viewed';
  static const String publicDeckCopied = 'public_deck_copied';
  static const String publicDecksSearched = 'public_decks_searched';
}

/// Property keys reused across multiple events.
abstract final class AnalyticsProperties {
  static const String screenName = 'screen_name';
  static const String provider = 'provider';
  static const String cardCount = 'card_count';
  static const String isQuickPlay = 'is_quick_play';
  static const String correctCount = 'correct_count';
  static const String isColdStart = 'is_cold_start';
  static const String source = 'source';
  static const String refined = 'refined';
  static const String generationMs = 'generation_ms';
  static const String reason = 'reason';
  static const String stage = 'stage';
  static const String deckId = 'deck_id';
  static const String field = 'field';
  static const String wasEdited = 'was_edited';
  static const String isCorrect = 'is_correct';
  static const String hasCardId = 'has_card_id';
  static const String durationMs = 'duration_ms';
  static const String trigger = 'trigger';
  static const String limitType = 'limit_type';
  static const String offering = 'offering';
  static const String plan = 'plan';
  static const String publicDeckId = 'public_deck_id';
  static const String category = 'category';
  static const String resultsCount = 'results_count';
}
