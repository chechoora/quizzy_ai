class QuizzyBackendException implements Exception {
  final String message;

  QuizzyBackendException(this.message);

  @override
  String toString() {
    return 'QuizzyBackendException: $message';
  }
}
