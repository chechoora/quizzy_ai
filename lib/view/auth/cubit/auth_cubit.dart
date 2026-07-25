import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authService,
    required this.inAppPurchaseService,
    required this.settingsService,
    required this.isSubscriptionOnly,
    required this.logger,
  }) : super(const AuthIdleState());

  final AuthService authService;
  final InAppPurchaseService inAppPurchaseService;
  final SettingsService settingsService;

  /// When true (the `quizzypro` flavor) a resumed/linked Quizzy AI
  /// subscription should be set as the default validator right after login.
  final bool isSubscriptionOnly;
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
      await _initUserRecords();
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

  /// Ensures the local user row and its settings row exist before anything
  /// else in the login flow (e.g. [_applyQuizzyAiEntitlement]) writes into
  /// user settings. See [SettingsService.initUserRecords].
  Future<void> _initUserRecords() async {
    logger.d('initUserRecords: ensuring user and settings rows exist');
    try {
      await settingsService.initUserRecords();
    } catch (e, stackTrace) {
      logger.e('initUserRecords: failed', ex: e, stacktrace: stackTrace);
    }
  }

  Future<void> _linkPurchases(String firebaseUid) async {
    logger.d('linkPurchases: uid=$firebaseUid');
    try {
      await inAppPurchaseService.logInUser(firebaseUid);
      if (isSubscriptionOnly) {
        await _applyQuizzyAiEntitlement();
      }
    } catch (e, stackTrace) {
      logger.e('linkPurchases: failed uid=$firebaseUid',
          ex: e, stacktrace: stackTrace);
    }
  }

  /// If the account being linked already holds an active Quizzy AI
  /// subscription (e.g. a clean install where the user logs in and their
  /// prior purchase resumes), set it as the default validator and deck
  /// generator right away instead of leaving the `ml` default in place.
  Future<void> _applyQuizzyAiEntitlement() async {
    logger.d('applyQuizzyAiEntitlement: checking subscription');
    final isSubscribed = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.quizzyAi);
    if (!isSubscribed) {
      logger.d('applyQuizzyAiEntitlement: not subscribed, skipping');
      return;
    }
    await settingsService.updateValidatorType(AnswerValidatorType.quizzyAI);
    await settingsService
        .updateDeckGenerationAiType(AnswerValidatorType.quizzyAI);
    logger.i('applyQuizzyAiEntitlement: Quizzy AI set as default validator '
        'and deck generator');
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