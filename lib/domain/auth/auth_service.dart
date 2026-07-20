import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';

/// Thrown when the user cancels/aborts an interactive sign-in flow.
///
/// Callers should treat this as a benign no-op (no error surfaced to the user),
/// as opposed to [AuthException] which represents a genuine failure.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// Thrown when a sign-in / sign-out operation fails for a real reason.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Abstraction over the authentication backend.
///
/// The concrete implementation ([FirebaseAuthService]) is registered in
/// `lib/di/di.dart` and consumed via `getIt<AuthService>()`.
abstract class AuthService {
  /// The currently signed-in account, or `null` when signed out.
  AuthUser? get currentUser;

  /// Emits the current account on every auth-state change (`null` on sign-out).
  Stream<AuthUser?> get authStateChanges;

  /// The current account's Firebase ID token, or `null` when signed out.
  ///
  /// Used to authenticate requests to backends expecting a Firebase-issued
  /// bearer token.
  Future<String?> getIdToken();

  /// Starts the interactive Google sign-in flow.
  ///
  /// Throws [AuthCancelledException] if the user aborts, [AuthException] on failure.
  Future<AuthUser> signInWithGoogle();

  /// Starts the interactive Apple sign-in flow.
  ///
  /// Throws [AuthCancelledException] if the user aborts, [AuthException] on failure.
  Future<AuthUser> signInWithApple();

  /// Signs the current account out.
  Future<void> signOut();

  /// Permanently deletes the current account.
  ///
  /// May transparently re-authenticate the user if the backend requires a
  /// recent login. Throws [AuthCancelledException] if the user aborts that
  /// re-authentication, [AuthException] on failure.
  Future<void> deleteAccount();
}