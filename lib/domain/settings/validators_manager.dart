import 'package:flutter/foundation.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
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
  final InAppPurchaseService inAppPurchaseService;

  ValidatorsManager({
    required this.userRepository,
    required this.userSettingsRepository,
    required this.onDeviceAIService,
    required this.inAppPurchaseService,
  });

  Future<List<ValidatorItem>> getValidators() async {
    final user = await userRepository.fetchCurrentUser();
    final settings = await userSettingsRepository.fetchUserSettings(user.id);

    final validators = <ValidatorItem>[];
    for (var type in AnswerValidatorType.values) {
      final isAvailable = await _isValidatorsAvailable(type);
      if (!isAvailable) continue;
      final config = await _getConfigValidator(type, settings);
      validators.add(ValidatorItem(
        type: type,
        validatorConfig: config,
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

  Future<ValidatorConfig?> _getConfigValidator(
      AnswerValidatorType type, UserSettingsItem settings) async {
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
        return null; // On-device AI doesn't need an API key
      case AnswerValidatorType.quizzyAI:
        return PurchaseConfig(
            isPurchased: await inAppPurchaseService
                .isFeaturePurchased(InAppPurchaseFeature.quizzyAi));
    }
  }

  Future _isValidatorsAvailable(AnswerValidatorType type) async {
    switch (type) {
      case AnswerValidatorType.claude:
      case AnswerValidatorType.gemini:
      case AnswerValidatorType.openAI:
      case AnswerValidatorType.ml:
      case AnswerValidatorType.ollama:
        return true;
      case AnswerValidatorType.quizzyAI:
        return false;
      case AnswerValidatorType.onDeviceAI:
        return defaultTargetPlatform == TargetPlatform.iOS &&
            await onDeviceAIService.isOnDeviceAIAvailable();
    }
  }
}
