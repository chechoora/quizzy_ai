enum AnswerValidatorType {
  onDeviceAI,
  claude,
  openAI,
  gemini,
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
      case AnswerValidatorType.ml:
        return 'ML Model';
    }
  }
}
