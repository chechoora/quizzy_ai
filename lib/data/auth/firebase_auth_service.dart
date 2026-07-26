import 'package:firebase_auth/firebase_auth.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// [AuthService] backed by Firebase Authentication.
///
/// Both Google and Apple use Firebase's federated `signInWithProvider(...)`
/// flow, so no provider-specific SDKs are required.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required FirebaseAuth firebaseAuth,
    required this.logger,
    String? authDomain,
  }) : _firebaseAuth = firebaseAuth {
    if (authDomain != null && authDomain.isNotEmpty) {
      _firebaseAuth.customAuthDomain = authDomain;
      logger.i('FirebaseAuthService: using custom auth domain $authDomain');
    }
  }

  final FirebaseAuth _firebaseAuth;
  final Logger logger;

  /// Firebase error codes that mean the user dismissed the flow themselves.
  static const _cancelCodes = {
    'canceled',
    'cancelled',
    'web-context-canceled',
    'user-canceled',
    'user-cancelled',
  };

  @override
  AuthUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  Future<String?> getIdToken() async {
    logger.d('getIdToken: starting');
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      logger.w('getIdToken: no signed-in account');
      return null;
    }
    try {
      final token = await user.getIdToken();
      logger.d('getIdToken: success');
      return token;
    } catch (e, stackTrace) {
      logger.e('getIdToken: failed', ex: e, stacktrace: stackTrace);
      return null;
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() {
    logger.i('signInWithGoogle: starting');
    return _signInWithProvider(GoogleAuthProvider(), providerName: 'Google');
  }

  @override
  Future<AuthUser> signInWithApple() {
    logger.i('signInWithApple: starting');
    final provider = AppleAuthProvider()..addScope('email');
    return _signInWithProvider(provider, providerName: 'Apple');
  }

  @override
  Future<void> signOut() async {
    logger.i('signOut: starting');
    try {
      await _firebaseAuth.signOut();
      logger.i('signOut: success');
    } catch (e, stackTrace) {
      logger.e('signOut: failed', ex: e, stacktrace: stackTrace);
      throw AuthException('Failed to sign out: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    logger.i('deleteAccount: starting');
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      logger.w('deleteAccount: no signed-in account');
      throw const AuthException('No signed-in account to delete');
    }
    try {
      await user.delete();
      logger.i('deleteAccount: success');
    } on FirebaseAuthException catch (e, stackTrace) {
      if (e.code == 'requires-recent-login') {
        logger.w('deleteAccount: requires recent login, re-authenticating');
        await _reauthenticateAndDelete(user);
        return;
      }
      if (_cancelCodes.contains(e.code)) {
        logger.w('deleteAccount: cancelled by user (${e.code})');
        throw const AuthCancelledException();
      }
      logger.e('deleteAccount: failed (${e.code})',
          ex: e, stacktrace: stackTrace);
      throw AuthException(e.message ?? 'Failed to delete account');
    } catch (e, stackTrace) {
      logger.e('deleteAccount: failed', ex: e, stacktrace: stackTrace);
      throw AuthException('Failed to delete account: $e');
    }
  }

  Future<void> _reauthenticateAndDelete(User user) async {
    try {
      await user.reauthenticateWithProvider(_providerFor(user));
      await user.delete();
      logger.i('deleteAccount: success after re-authentication');
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_cancelCodes.contains(e.code)) {
        logger.w('deleteAccount: re-authentication cancelled (${e.code})');
        throw const AuthCancelledException();
      }
      logger.e('deleteAccount: re-authentication failed (${e.code})',
          ex: e, stacktrace: stackTrace);
      throw AuthException(e.message ?? 'Failed to delete account');
    }
  }

  /// Picks the federated provider matching how the user originally signed in,
  /// so re-authentication uses the same identity.
  AuthProvider _providerFor(User user) {
    final providerId =
        user.providerData.isNotEmpty ? user.providerData.first.providerId : '';
    switch (providerId) {
      case 'apple.com':
        return AppleAuthProvider()..addScope('email');
      case 'google.com':
      default:
        return GoogleAuthProvider();
    }
  }

  Future<AuthUser> _signInWithProvider(
    AuthProvider provider, {
    required String providerName,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithProvider(provider);
      final user = _mapUser(credential.user);
      if (user == null) {
        logger.e('$providerName sign-in returned no user');
        throw AuthException('$providerName sign-in returned no user');
      }
      logger.i('$providerName sign-in success: uid=${user.uid}');
      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_cancelCodes.contains(e.code)) {
        logger.w('$providerName sign-in cancelled by user (${e.code})');
        throw const AuthCancelledException();
      }
      logger.e('$providerName sign-in failed (${e.code})',
          ex: e, stacktrace: stackTrace);
      throw AuthException(e.message ?? '$providerName sign-in failed');
    } catch (e, stackTrace) {
      logger.e('$providerName sign-in failed', ex: e, stacktrace: stackTrace);
      throw AuthException('$providerName sign-in failed: $e');
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}