import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

import '../user_settings/model/user_settings_item.dart' show UserSettingsItem;

class ValidatorsManager {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;
  final OnDeviceAIService onDeviceAIService;

  ValidatorsManager({
    required this.userRepository,
    required this.userSettingsRepository,
    required this.onDeviceAIService,
  });

  Future<List<ValidatorItem>> getValidators() async {
    final user = await userRepository.fetchCurrentUser();
    final settings = await userSettingsRepository.fetchUserSettings(user.id);

    final validators = <ValidatorItem>[];
    for (var type in AnswerValidatorType.values) {
      final isEnabled = await _isValidatorEnabled(type);
      final apiKey = _getApiKeyForValidator(type, settings);
      validators.add(ValidatorItem(
        type: type,
        isEnabled: isEnabled,
        apiKey: apiKey,
      ));
    }
    return validators;
  }

  Future<List<ValidatorItem>> getValidatorsWithApiKeys() async {
    final allValidators = await getValidators();
    return allValidators.where((validator) {
      // On-device AI doesn't need API key, just needs to be enabled
      if (validator.type == AnswerValidatorType.onDeviceAI) {
        return validator.isEnabled;
      }
      // Cloud validators need both enabled status AND API keys
      return validator.isEnabled &&
          validator.apiKey != null &&
          validator.apiKey!.isNotEmpty;
    }).toList();
  }

  String? _getApiKeyForValidator(
      AnswerValidatorType type, UserSettingsItem settings) {
    switch (type) {
      case AnswerValidatorType.gemini:
        return settings.geminiApiKey;
      case AnswerValidatorType.claude:
        return settings.claudeApiKey;
      case AnswerValidatorType.openAI:
        return settings.openAiApiKey;
      case AnswerValidatorType.onDeviceAI:
        return null; // On-device AI doesn't need an API key
    }
  }

  Future<bool> _isValidatorEnabled(AnswerValidatorType type) async {
    switch (type) {
      case AnswerValidatorType.claude:
      case AnswerValidatorType.gemini:
      case AnswerValidatorType.openAI:
        return true;
      case AnswerValidatorType.onDeviceAI:
        return onDeviceAIService.isOnDeviceAIAvailable();
    }
  }
}
