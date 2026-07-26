import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class SettingsMenuCubit extends Cubit<SettingsMenuState> {
  SettingsMenuCubit({
    required AppConfig appConfig,
    required this.authService,
    required this.logger,
  })  : _enableByok = appConfig.enableByok,
        _requireAuth = appConfig.requireAuth,
        super(SettingsMenuIdleState(
          enableByok: appConfig.enableByok,
          requireAuth: appConfig.requireAuth,
        ));

  final AuthService authService;
  final Logger logger;
  final bool _enableByok;
  final bool _requireAuth;

  SettingsMenuIdleState get _idle => SettingsMenuIdleState(
        enableByok: _enableByok,
        requireAuth: _requireAuth,
      );

  Future<void> signOut() async {
    logger.i('signOut: starting');
    emit(const SettingsMenuLoadingState());
    try {
      await authService.signOut();
      logger.i('signOut: success');
      // Navigation back to AuthScreen is driven by the authStateChanges
      // listener wired in mainCommon.
      emit(_idle);
    } catch (e, stackTrace) {
      logger.e('signOut: failed', ex: e, stacktrace: stackTrace);
      emit(SettingsMenuErrorState(
        e is AuthException ? e.message : e.toString(),
      ));
      emit(_idle);
    }
  }

  Future<void> deleteAccount() async {
    logger.i('deleteAccount: starting');
    emit(const SettingsMenuLoadingState());
    try {
      await authService.deleteAccount();
      logger.i('deleteAccount: success');
      // Deletion signs the user out; the authStateChanges listener in
      // mainCommon redirects to the AuthScreen.
      emit(_idle);
    } on AuthCancelledException {
      logger.w('deleteAccount: cancelled by user');
      emit(_idle);
    } catch (e, stackTrace) {
      logger.e('deleteAccount: failed', ex: e, stacktrace: stackTrace);
      emit(SettingsMenuErrorState(
        e is AuthException ? e.message : e.toString(),
      ));
      emit(_idle);
    }
  }
}

abstract class SettingsMenuState extends Equatable {
  const SettingsMenuState();
}

abstract class BuilderState extends SettingsMenuState {
  const BuilderState();
}

abstract class ListenerState extends SettingsMenuState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class SettingsMenuIdleState extends BuilderState {
  final bool enableByok;
  final bool requireAuth;

  const SettingsMenuIdleState({
    required this.enableByok,
    required this.requireAuth,
  });

  @override
  List<Object?> get props => [enableByok, requireAuth];
}

class SettingsMenuLoadingState extends BuilderState {
  const SettingsMenuLoadingState();

  @override
  List<Object?> get props => [];
}

class SettingsMenuErrorState extends ListenerState {
  final String error;

  const SettingsMenuErrorState(this.error);

  @override
  List<Object?> get props => [error, super.props];
}