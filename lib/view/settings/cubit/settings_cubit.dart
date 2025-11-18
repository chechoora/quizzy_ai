import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.settingsService,
    required this.validatorsManager,
    required this.userRepository,
    required this.userSettingsRepository,
  }) : super(const SettingsLoadingState()) {
    _logger = Logger.withTag('SettingsCubit');
  }

  final SettingsService settingsService;
  final ValidatorsManager validatorsManager;
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  late final Logger _logger;

  Future<void> loadSettings() async {
    emit(const SettingsLoadingState());
    try {
      final validatorType = await settingsService.getCurrentValidatorType();
      final validators = await validatorsManager.getValidators();
      emit(SettingsDataState(
        validatorType: validatorType,
        validators: validators,
      ));
    } catch (e, stackTrace) {
      _logger.e('Failed to load settings', ex: e, stacktrace: stackTrace);
      emit(SettingsErrorState(
        error: e.toString(),
        previousValidatorType: null,
      ));
    }
  }

  Future<void> updateValidator(AnswerValidatorType newValidator) async {
    final currentState = state;
    if (currentState is! SettingsDataState) return;

    if (currentState.validatorType == newValidator) return;

    try {
      await settingsService.updateValidatorType(newValidator);
      emit(SettingsDataState(
        validatorType: newValidator,
        validators: currentState.validators,
      ));
      emit(SettingsUpdateSuccessState(validatorType: newValidator));
      _logger.i('Updated validator to: ${newValidator.toDisplayString()}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update validator', ex: e, stacktrace: stackTrace);
      emit(SettingsErrorState(
        error: e.toString(),
        previousValidatorType: currentState.validatorType,
      ));
    }
  }

  Future<void> updateApiKey(AnswerValidatorType validatorType, String? apiKey) async {
    final currentState = state;
    if (currentState is! SettingsDataState) return;

    try {
      final user = await userRepository.fetchCurrentUser();

      // Update the appropriate API key based on validator type
      switch (validatorType) {
        case AnswerValidatorType.gemini:
          await userSettingsRepository.setGeminiApiKey(user.id, apiKey);
          break;
        case AnswerValidatorType.claude:
          await userSettingsRepository.setClaudeApiKey(user.id, apiKey);
          break;
        case AnswerValidatorType.openAI:
          await userSettingsRepository.setOpenAiApiKey(user.id, apiKey);
          break;
        case AnswerValidatorType.onDeviceAI:
          // On-device AI doesn't need an API key
          return;
      }

      // Reload validators to reflect the updated API key
      final validators = await validatorsManager.getValidators();
      emit(SettingsDataState(
        validatorType: currentState.validatorType,
        validators: validators,
      ));
      emit(SettingsApiKeyUpdatedState(validatorType: validatorType));
      _logger.i('Updated API key for: ${validatorType.toDisplayString()}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update API key', ex: e, stacktrace: stackTrace);
      emit(SettingsErrorState(
        error: 'Failed to update API key: ${e.toString()}',
        previousValidatorType: currentState.validatorType,
      ));
    }
  }
}

abstract class SettingsState extends Equatable {
  const SettingsState();
}

abstract class BuilderState extends SettingsState {
  const BuilderState();
}

abstract class ListenerState extends SettingsState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class SettingsLoadingState extends BuilderState {
  const SettingsLoadingState();

  @override
  List<Object?> get props => [];
}

class SettingsDataState extends BuilderState {
  final AnswerValidatorType validatorType;
  final List<ValidatorItem> validators;

  const SettingsDataState({
    required this.validatorType,
    required this.validators,
  });

  @override
  List<Object?> get props => [validatorType, validators];
}

class SettingsUpdateSuccessState extends ListenerState {
  final AnswerValidatorType validatorType;

  const SettingsUpdateSuccessState({required this.validatorType});

  @override
  List<Object?> get props => [validatorType, super.props];
}

class SettingsApiKeyUpdatedState extends ListenerState {
  final AnswerValidatorType validatorType;

  const SettingsApiKeyUpdatedState({required this.validatorType});

  @override
  List<Object?> get props => [validatorType, super.props];
}

class SettingsErrorState extends ListenerState {
  final String error;
  final AnswerValidatorType? previousValidatorType;

  const SettingsErrorState({
    required this.error,
    required this.previousValidatorType,
  });

  @override
  List<Object?> get props => [error, previousValidatorType, super.props];
}