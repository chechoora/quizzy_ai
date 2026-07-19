/// Build flavor of the application.
enum Flavor {
  /// Free / bring-your-own-key build ("Quizzy AI").
  quizzy,

  /// Future subscription-only build ("Quizzy AI Pro").
  quizzyPro,
}

/// Compile-time application configuration, built by each flavor entry point
/// (`main_quizzy.dart` / `main_quizzypro.dart`) and injected via GetIt.
///
/// The [enableByok] and [requireAuth] flags are declared for later use and are
/// intentionally NOT consumed anywhere yet.
class AppConfig {
  /// Human-readable app name (also used natively for the display name).
  final String appName;

  /// The active build flavor.
  final Flavor flavor;

  /// Whether bring-your-own-key (BYOK) features are enabled. Not consumed yet.
  final bool enableByok;

  /// Whether authentication is required to use the app. Not consumed yet.
  final bool requireAuth;

  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.enableByok,
    required this.requireAuth,
  });
}
