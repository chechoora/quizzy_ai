/// Build flavor of the application.
enum Flavor {
  /// Free / bring-your-own-key build ("Quizzy AI").
  quizzy,

  /// Future subscription-only build ("Quizzy AI Pro").
  quizzyPro,
}

/// Compile-time application configuration, built by each flavor entry point
/// (`main_quizzy.dart` / `main_quizzypro.dart`) and injected via GetIt.
class AppConfig {
  /// Human-readable app name (also used natively for the display name).
  final String appName;

  /// The active build flavor.
  final Flavor flavor;

  /// Whether bring-your-own-key (BYOK) features are enabled.
  final bool enableByok;

  /// Whether authentication is required to use the app.
  final bool requireAuth;

  /// Whether iCloud backup/restore is enabled. `quizzyPro` has no need for it
  /// (it's account/subscription-backed instead), so it stays off there.
  final bool enableIcloudBackup;

  /// Whether the app offers only the Quizzy AI subscription. `quizzyPro`
  /// sets this to true (subscription unlocks everything, no separate
  /// one-time purchase); `quizzy` sets it to false (one-time "unlimited
  /// decks/cards" purchase only, no Quizzy AI subscription/validator).
  final bool isSubscriptionOnly;

  /// Whether two-way remote sync with the quizzy-ai-pro backend is enabled.
  /// `quizzyPro` is account/subscription-backed and needs it; `quizzy` is
  /// local-only and stays off.
  final bool enableRemoteSync;

  /// Whether product-usage analytics are uploaded to the quizzy-ai-pro
  /// backend. `quizzyPro` is account-backed and needs it; `quizzy` has no
  /// backend account to attribute events to, so it uses a no-op
  /// [AnalyticsService] instead.
  final bool enableAnalytics;

  /// Whether the quizzy-ai-pro backend is available to this flavor.
  /// `quizzyPro` is account-backed and has one; `quizzy` is local-only and
  /// stays off. Gates backend-dependent features like public decks.
  final bool backendSupported;

  /// Sentry DSN for error monitoring and logs. Empty string disables Sentry.
  /// `quizzyPro` has a Sentry project to attribute events to; `quizzy` does
  /// not, so it stays empty.
  final String sentryDsn;

  /// Custom Firebase Auth domain shown on the native sign-in sheet, applied
  /// via `FirebaseAuth.customAuthDomain` (native has no `FirebaseOptions`
  /// field for this — see `FirebaseAuthService`). `quizzyPro` has a custom
  /// domain; `quizzy` has none, so it stays null.
  final String? authDomain;

  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.enableByok,
    required this.requireAuth,
    required this.enableIcloudBackup,
    required this.isSubscriptionOnly,
    required this.enableRemoteSync,
    required this.enableAnalytics,
    required this.backendSupported,
    required this.sentryDsn,
    this.authDomain,
  });

  bool getIsDeckGeneratorEditEnabled() {
    return enableByok;
  }
}
