import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class DeckGenerationCubit extends Cubit<DeckGenerationState> {
  DeckGenerationCubit({
    required this.settingsService,
    required this.validatorsManager,
    required this.userRepository,
    required this.userSettingsRepository,
  }) : super(const DeckGenerationLoadingState()) {
    _logger = Logger.withTag('DeckGenerationCubit');
  }

  final SettingsService settingsService;
  final ValidatorsManager validatorsManager;
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  late final Logger _logger;

  Future<void> loadSettings() async {
    emit(const DeckGenerationLoadingState());
    try {
      final selectedType =
          await settingsService.getCurrentDeckGenerationAiType();
      final providers = await _loadProviders();
      emit(DeckGenerationDataState(
        selectedType: selectedType,
        providers: providers,
      ));
    } catch (e, stackTrace) {
      _logger.e('Failed to load deck generation settings',
          ex: e, stacktrace: stackTrace);
      emit(DeckGenerationErrorState(error: e.toString()));
    }
  }

  Future<void> updateType(AnswerValidatorType newType) async {
    final currentState = state;
    if (currentState is! DeckGenerationDataState) return;
    if (currentState.selectedType == newType) return;

    try {
      await settingsService.updateDeckGenerationAiType(newType);
      emit(DeckGenerationUpdateSuccessState(type: newType));
      emit(DeckGenerationDataState(
        selectedType: newType,
        providers: currentState.providers,
      ));
      _logger.i('Updated deck generation AI to: ${newType.toDisplayString()}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update deck generation AI',
          ex: e, stacktrace: stackTrace);
      emit(DeckGenerationErrorState(error: e.toString()));
      emit(currentState);
    }
  }

  Future<void> updateApiKeyConfig(
      AnswerValidatorType type, ApiKeyConfig? config) async {
    final currentState = state;
    if (currentState is! DeckGenerationDataState) return;

    try {
      final user = await userRepository.fetchCurrentUser();

      switch (type) {
        case AnswerValidatorType.gemini:
          await userSettingsRepository.setGeminiConfig(user.id, config);
          break;
        case AnswerValidatorType.claude:
          await userSettingsRepository.setClaudeConfig(user.id, config);
          break;
        case AnswerValidatorType.openAI:
          await userSettingsRepository.setOpenAiConfig(user.id, config);
          break;
        case AnswerValidatorType.onDeviceAI:
        case AnswerValidatorType.ml:
        case AnswerValidatorType.ollama:
        case AnswerValidatorType.quizzyAI:
          throw ArgumentError('$type does not use ApiKeyConfig');
      }

      final providers = await _loadProviders();
      emit(DeckGenerationApiKeyUpdatedState(type: type));
      emit(DeckGenerationDataState(
        selectedType: currentState.selectedType,
        providers: providers,
      ));
      _logger.i('Updated config for: ${type.toDisplayString()}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update config', ex: e, stacktrace: stackTrace);
      emit(DeckGenerationErrorState(
        error: 'Failed to update config: ${e.toString()}',
      ));
      emit(currentState);
    }
  }

  Future<void> updateOpenSourceConfig(
    AnswerValidatorType type,
    OpenSourceConfig? config,
  ) async {
    final currentState = state;
    if (currentState is! DeckGenerationDataState) return;

    try {
      final user = await userRepository.fetchCurrentUser();

      switch (type) {
        case AnswerValidatorType.ollama:
          await userSettingsRepository.setOllamaConfig(user.id, config);
          break;
        default:
          throw ArgumentError('$type does not support OpenSourceConfig');
      }

      final providers = await _loadProviders();
      emit(DeckGenerationApiKeyUpdatedState(type: type));
      emit(DeckGenerationDataState(
        selectedType: currentState.selectedType,
        providers: providers,
      ));
      _logger.i('Updated config for: ${type.toDisplayString()}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update config', ex: e, stacktrace: stackTrace);
      emit(DeckGenerationErrorState(
        error: 'Failed to update config: ${e.toString()}',
      ));
      emit(currentState);
    }
  }

  /// The provider options offered for deck generation, restricted to
  /// [kDeckGenerationAiTypes] (no On-Device AI / ML Model). Reuses the
  /// validator items so icons, descriptions and premium gating are shared.
  Future<List<ValidatorItem>> _loadProviders() async {
    final validators = await validatorsManager.getValidators();
    return validators
        .where((v) => kDeckGenerationAiTypes.contains(v.type))
        .toList();
  }
}

abstract class DeckGenerationState extends Equatable {
  const DeckGenerationState();
}

abstract class BuilderState extends DeckGenerationState {
  const BuilderState();
}

abstract class ListenerState extends DeckGenerationState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class DeckGenerationLoadingState extends BuilderState {
  const DeckGenerationLoadingState();

  @override
  List<Object?> get props => [];
}

class DeckGenerationDataState extends BuilderState {
  final AnswerValidatorType selectedType;
  final List<ValidatorItem> providers;

  const DeckGenerationDataState({
    required this.selectedType,
    required this.providers,
  });

  @override
  List<Object?> get props => [selectedType, providers];
}

class DeckGenerationUpdateSuccessState extends ListenerState {
  final AnswerValidatorType type;

  const DeckGenerationUpdateSuccessState({required this.type});

  @override
  List<Object?> get props => [type, super.props];
}

class DeckGenerationApiKeyUpdatedState extends ListenerState {
  final AnswerValidatorType type;

  const DeckGenerationApiKeyUpdatedState({required this.type});

  @override
  List<Object?> get props => [type, super.props];
}

class DeckGenerationErrorState extends ListenerState {
  final String error;

  const DeckGenerationErrorState({required this.error});

  @override
  List<Object?> get props => [error, super.props];
}
