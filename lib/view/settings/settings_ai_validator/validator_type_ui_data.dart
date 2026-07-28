import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/l10n/app_localizations.dart';

extension AnswerValidatorTypeDisplayName on AnswerValidatorType {
  String displayName(AppLocalizations l10n) {
    switch (this) {
      case AnswerValidatorType.gemini:
        return l10n.validatorNameGemini;
      case AnswerValidatorType.onDeviceAI:
        return l10n.validatorNameOnDeviceAI;
      case AnswerValidatorType.claude:
        return l10n.validatorNameClaude;
      case AnswerValidatorType.openAI:
        return l10n.validatorNameOpenAI;
      case AnswerValidatorType.ollama:
        return l10n.validatorNameOllama;
      case AnswerValidatorType.ml:
        return l10n.validatorNameMl;
      case AnswerValidatorType.quizzyAI:
        return l10n.validatorNameQuizzyAI;
    }
  }
}

class ValidatorTypeUIData {
  final String iconAsset;
  final String Function(AppLocalizations l10n) getDescription;

  const ValidatorTypeUIData({
    required this.iconAsset,
    required this.getDescription,
  });
}

ValidatorTypeUIData getValidatorUIData(AnswerValidatorType type) {
  return switch (type) {
    AnswerValidatorType.quizzyAI => ValidatorTypeUIData(
        iconAsset: 'assets/icons/quizzy_ai.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorQuizzyAIDescription,
      ),
    AnswerValidatorType.onDeviceAI => ValidatorTypeUIData(
        iconAsset: 'assets/icons/on_device_ai.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorOnDeviceDescription,
      ),
    AnswerValidatorType.claude => ValidatorTypeUIData(
        iconAsset: 'assets/icons/calude_ai.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorClaudeDescription,
      ),
    AnswerValidatorType.openAI => ValidatorTypeUIData(
        iconAsset: 'assets/icons/open_ai.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorOpenAIDescription,
      ),
    AnswerValidatorType.gemini => ValidatorTypeUIData(
        iconAsset: 'assets/icons/gemini_ai.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorGeminiDescription,
      ),
    AnswerValidatorType.ml => ValidatorTypeUIData(
        iconAsset: 'assets/icons/ml.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorMlDescription,
      ),
    AnswerValidatorType.ollama => ValidatorTypeUIData(
        iconAsset: 'assets/icons/ollama.svg',
        getDescription: (l10n) => l10n.settingsAiValidatorOllamaDescription,
      ),
  };
}
