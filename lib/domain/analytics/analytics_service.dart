/// Tracks product-usage events, batching and uploading them to the
/// quizzy-ai-pro backend. [NoopAnalyticsService] (the `quizzy` flavor) and
/// [RemoteAnalyticsService] (the `quizzypro` flavor) both implement this so
/// callers never need to branch on flavor.
abstract class AnalyticsService {
  /// Begins any background scheduling (periodic flush, auth/lifecycle
  /// listeners). Safe to call once at app startup; a no-op on repeat calls.
  void start();

  /// Records an event. Never throws — failures are logged and swallowed so a
  /// tracking call can never break the calling feature code. [properties]
  /// are whitelisted and enriched server-side; unknown keys are stripped.
  Future<void> track(String name, {Map<String, dynamic>? properties});

  /// Cancels any timers/subscriptions started by [start].
  void dispose();
}
