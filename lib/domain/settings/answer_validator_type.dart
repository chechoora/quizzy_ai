enum AnswerValidatorType {
  quizzyAI,
  onDeviceAI,
  claude,
  openAI,
  gemini,
  ollama,
  ml;

  String toDisplayString() {
    switch (this) {
      case AnswerValidatorType.gemini:
        return 'Gemini AI';
      case AnswerValidatorType.onDeviceAI:
        return 'On-Device AI (experimental)';
      case AnswerValidatorType.claude:
        return 'Claude AI';
      case AnswerValidatorType.openAI:
        return 'OpenAI';
      case AnswerValidatorType.ollama:
        return 'Ollama (Local, experimental)';
      case AnswerValidatorType.ml:
        return 'ML Model';
      case AnswerValidatorType.quizzyAI:
        return 'Quizzy AI';
    }
  }
}

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

  const ApiKeyConfig({required this.apiKey});

  @override
  bool get isValid => apiKey.isNotEmpty;
}

class OpenSourceConfig extends ValidatorConfig {
  final String url;
  final String model;

  const OpenSourceConfig({
    required this.url,
    required this.model,
  });

  @override
  bool get isValid => url.isNotEmpty && model.isNotEmpty;
}
