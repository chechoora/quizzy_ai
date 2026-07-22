import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authService,
    required this.inAppPurchaseService,
    required this.logger,
  }) : super(const AuthIdleState());

  final AuthService authService;
  final InAppPurchaseService inAppPurchaseService;
  final Logger logger;

  Future<void> signInWithGoogle() =>
      _signIn(authService.signInWithGoogle, provider: 'Google');

  Future<void> signInWithApple() =>
      _signIn(authService.signInWithApple, provider: 'Apple');

  Future<void> _signIn(
    Future<AuthUser> Function() action, {
    required String provider,
  }) async {
    logger.d('signIn: provider=$provider');
    emit(const AuthLoadingState());
    try {
      final user = await action();
      logger.i('signIn: success provider=$provider uid=${user.uid}');
      await _linkPurchases(user.uid);
      emit(AuthSignedInState(user));
      emit(const AuthIdleState());
    } on AuthCancelledException {
      logger.w('signIn: cancelled provider=$provider');
      emit(const AuthIdleState());
    } catch (e, stackTrace) {
      logger.e('signIn: failed provider=$provider',
          ex: e, stacktrace: stackTrace);
      emit(AuthErrorState(e is AuthException ? e.message : e.toString()));
      emit(const AuthIdleState());
    }
  }

  Future<void> _linkPurchases(String firebaseUid) async {
    logger.d('linkPurchases: uid=$firebaseUid');
    try {
      await inAppPurchaseService.logInUser(firebaseUid);
    } catch (e, stackTrace) {
      logger.e('linkPurchases: failed uid=$firebaseUid',
          ex: e, stacktrace: stackTrace);
    }
  }
}

abstract class AuthState extends Equatable {
  const AuthState();
}

abstract class BuilderState extends AuthState {
  const BuilderState();
}

abstract class ListenerState extends AuthState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class AuthIdleState extends BuilderState {
  const AuthIdleState();

  @override
  List<Object?> get props => [];
}

class AuthLoadingState extends BuilderState {
  const AuthLoadingState();

  @override
  List<Object?> get props => [];
}

class AuthSignedInState extends ListenerState {
  final AuthUser user;

  const AuthSignedInState(this.user);

  @override
  List<Object?> get props => [user, super.props];
}

class AuthErrorState extends ListenerState {
  final String error;

  const AuthErrorState(this.error);

  @override
  List<Object?> get props => [error, super.props];
}