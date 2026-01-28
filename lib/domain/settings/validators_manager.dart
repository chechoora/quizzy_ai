import 'package:flutter/foundation.dart';
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
      final isAvailable = await _isValidatorsAvailable(type);
      if (!isAvailable) continue;
      final apiKey = _getConfigValidator(type, settings);
      validators.add(ValidatorItem(
        type: type,
        validatorConfig: apiKey,
      ));
    }
    return validators;
  }

  Future<List<ValidatorItem>> getEnabledValidators() async {
    final allValidators = await getValidators();
    return allValidators.where((validator) {
      // On-device AI doesn't need API key, just needs to be enabled
      if (validator.type == AnswerValidatorType.onDeviceAI ||
          validator.type == AnswerValidatorType.ml) {
        return true;
      }
      // Cloud validators need both enabled status AND API keys
      return validator.validatorConfig != null;
    }).toList();
  }

  ValidatorConfig? _getConfigValidator(
      AnswerValidatorType type, UserSettingsItem settings) {
    switch (type) {
      case AnswerValidatorType.gemini:
        return settings.geminiConfig;
      case AnswerValidatorType.claude:
        return settings.claudeConfig;
      case AnswerValidatorType.openAI:
        return settings.openConfig;
      case AnswerValidatorType.ollama:
        return settings.ollamaConfig;
      case AnswerValidatorType.onDeviceAI:
      case AnswerValidatorType.ml:
      case AnswerValidatorType.quizzyAI:
        return null; // On-device AI doesn't need an API key
    }
  }

  Future _isValidatorsAvailable(AnswerValidatorType type) async {
    switch (type) {
      case AnswerValidatorType.claude:
      case AnswerValidatorType.gemini:
      case AnswerValidatorType.openAI:
      case AnswerValidatorType.ml:
      case AnswerValidatorType.ollama:
      case AnswerValidatorType.quizzyAI:
        return true;
      case AnswerValidatorType.onDeviceAI:
        return defaultTargetPlatform == TargetPlatform.iOS &&
            await onDeviceAIService.isOnDeviceAIAvailable();
    }
  }
}
