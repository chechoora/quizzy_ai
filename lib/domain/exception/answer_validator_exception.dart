class AnswerValidatorException implements Exception {
  final String message;

  AnswerValidatorException(this.message);

  @override
  String toString() {
    return "AnswerValidatorException: $message";
  }
}
