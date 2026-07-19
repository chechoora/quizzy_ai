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

  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.enableByok,
    required this.requireAuth,
    required this.enableIcloudBackup,
    required this.isSubscriptionOnly,
  });

  bool getIsDeckGeneratorEditEnabled() {
    return enableByok;
  }
}
