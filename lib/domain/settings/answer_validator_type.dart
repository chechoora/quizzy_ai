enum AnswerValidatorType {
  gemini,
  onDeviceAI,
  textSimilarity;

  String toDisplayString() {
    switch (this) {
      case AnswerValidatorType.gemini:
        return 'Gemini AI';
      case AnswerValidatorType.onDeviceAI:
        return 'On-Device AI';
      case AnswerValidatorType.textSimilarity:
        return 'Text Similarity';
    }
  }
}