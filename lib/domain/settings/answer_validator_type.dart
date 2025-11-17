enum AnswerValidatorType {
  gemini,
  onDeviceAI,
  claude;

  String toDisplayString() {
    switch (this) {
      case AnswerValidatorType.gemini:
        return 'Gemini AI';
      case AnswerValidatorType.onDeviceAI:
        return 'On-Device AI';
      case AnswerValidatorType.claude:
        return 'Claude AI';
    }
  }
}
