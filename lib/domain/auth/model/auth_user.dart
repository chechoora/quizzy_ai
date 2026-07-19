import 'package:equatable/equatable.dart';

/// Domain representation of an authenticated account.
///
/// Deliberately decoupled from Firebase's `User` type so the UI / cubit layer
/// never depends on `firebase_auth` directly.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}