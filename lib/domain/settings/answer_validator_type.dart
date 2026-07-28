enum AnswerValidatorType {
  quizzyAI,
  onDeviceAI,
  claude,
  openAI,
  gemini,
  ollama,
  ml,
}

/// Providers offered for AI deck generation. Excludes On-Device AI and the
/// ML Model, which are answer-validation only.
const kDeckGenerationAiTypes = [
  AnswerValidatorType.claude,
  AnswerValidatorType.openAI,
  AnswerValidatorType.gemini,
  AnswerValidatorType.quizzyAI,
  AnswerValidatorType.ollama,
];

enum ValidatorCategory {
  cloud,
  onDevice,
  openSource,
}

extension AnswerValidatorTypeExtension on AnswerValidatorType {
  ValidatorCategory get category {
    switch (this) {
      case AnswerValidatorType.gemini:
      case AnswerValidatorType.claude:
      case AnswerValidatorType.openAI:
      case AnswerValidatorType.quizzyAI:
        return ValidatorCategory.cloud;
      case AnswerValidatorType.onDeviceAI:
      case AnswerValidatorType.ml:
        return ValidatorCategory.onDevice;
      case AnswerValidatorType.ollama:
        return ValidatorCategory.openSource;
    }
  }
}

sealed class ValidatorConfig {
  const ValidatorConfig();

  bool get isValid;
}

class ApiKeyConfig extends ValidatorConfig {
  final String apiKey;
  final String model;

  const ApiKeyConfig({
    required this.apiKey,
    required this.model,
  });

  factory ApiKeyConfig.empty() => const ApiKeyConfig(apiKey: '', model: '');

  @override
  bool get isValid => apiKey.isNotEmpty && model.isNotEmpty;
}

class OpenSourceConfig extends ValidatorConfig {
  final String url;
  final String model;

  const OpenSourceConfig({
    required this.url,
    required this.model,
  });

  factory OpenSourceConfig.empty() =>
      const OpenSourceConfig(url: '', model: '');

  @override
  bool get isValid => url.isNotEmpty && model.isNotEmpty;
}

class PurchaseConfig extends ValidatorConfig {
  const PurchaseConfig({required this.isPurchased});

  final bool isPurchased;

  @override
  bool get isValid => true;
}
