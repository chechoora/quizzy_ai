import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

class ValidatorsManager {
  final UserRepository userRepository;
  final OnDeviceAIService onDeviceAIService;

  ValidatorsManager({
    required this.userRepository,
    required this.onDeviceAIService,
  });

  Future<List<ValidatorItem>> getValidators() async {
    final user = await userRepository.fetchCurrentUser();
    final isPremium = user.isPremium;

    final validators = <ValidatorItem>[];
    for (var type in AnswerValidatorType.values) {
      final isEnabled = await _isValidatorEnabled(type, isPremium);
      validators.add(ValidatorItem(
        type: type,
        isEnabled: isEnabled,
      ));
    }
    return validators;
  }

  Future<bool> _isValidatorEnabled(
      AnswerValidatorType type, bool isPremium) async {
    switch (type) {
      case AnswerValidatorType.textSimilarity:
      case AnswerValidatorType.gemini:
        return true;
      case AnswerValidatorType.onDeviceAI:
        return onDeviceAIService.isOnDeviceAIAvailable();
    }
  }
}
