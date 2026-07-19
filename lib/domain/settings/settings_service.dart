import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_selection_data.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class SettingsService {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  final Map<AnswerValidatorType, IAnswerValidator> validators;

  /// When false (e.g. the `quizzypro` flavor) deck generation is forced to the
  /// managed Quizzy AI provider, since the bring-your-own-key generators are
  /// removed.
  final bool enableByok;

  SettingsService({
    required this.userRepository,
    required this.userSettingsRepository,
    required this.validators,
    required this.enableByok,
  });

  Future<AnswerValidatorType> getCurrentValidatorType() async {
    final user = await userRepository.fetchCurrentUser();
    final userSettings =
        await userSettingsRepository.fetchUserSettings(user.id);
    return userSettings.answerValidatorType;
  }

  Future<void> updateValidatorType(AnswerValidatorType validatorType) async {
    final user = await userRepository.fetchCurrentUser();
    await userSettingsRepository.updateAnswerValidatorType(
        user.id, validatorType);
  }

  Future<AnswerValidatorType> getCurrentDeckGenerationAiType() async {
    // With BYOK disabled the only surviving generator is the managed Quizzy AI
    // provider, so ignore any stored (potentially BYOK) selection.
    if (!enableByok) return AnswerValidatorType.quizzyAI;
    final user = await userRepository.fetchCurrentUser();
    final userSettings =
        await userSettingsRepository.fetchUserSettings(user.id);
    return userSettings.deckGenerationAiType;
  }

  Future<void> updateDeckGenerationAiType(AnswerValidatorType type) async {
    final user = await userRepository.fetchCurrentUser();
    await userSettingsRepository.updateDeckGenerationAiType(user.id, type);
  }

  Future<IAnswerValidator> getAnswerValidator() async {
    final validatorType = await getCurrentValidatorType();
    return validators[validatorType]!;
  }

  Future<ValidatorSelectionData> getValidatorSelectionData(
    ValidatorsManager validatorsManager,
  ) async {
    final currentValidator = await getCurrentValidatorType();
    final availableValidators = await validatorsManager.getEnabledValidators();
    return ValidatorSelectionData(
      selectedValidator: currentValidator,
      availableValidators: availableValidators,
    );
  }
}
