import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class SettingsService {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  final Map<AnswerValidatorType, IAnswerValidator> validators;

  SettingsService({
    required this.userRepository,
    required this.userSettingsRepository,
    required this.validators,
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

  Future<IAnswerValidator> getAnswerValidator() async {
    final validatorType = await getCurrentValidatorType();
    return validators[validatorType]!;
  }
}
