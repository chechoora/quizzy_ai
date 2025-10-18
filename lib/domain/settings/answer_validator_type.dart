enum AnswerValidatorType {
  gemini,
  onDeviceAI,
  custom;

  String toDisplayString() {
    switch (this) {
      case AnswerValidatorType.gemini:
        return 'Gemini AI';
      case AnswerValidatorType.onDeviceAI:
        return 'On-Device AI';
      case AnswerValidatorType.custom:
        return 'Custom';
    }
  }
}
