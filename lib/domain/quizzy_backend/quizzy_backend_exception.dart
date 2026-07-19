class QuizzyBackendException implements Exception {
  final String message;

  /// The HTTP status code that caused this exception, when known (e.g. used
  /// by the sync service to treat a 404 on a delete as "already gone").
  final int? statusCode;

  QuizzyBackendException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'QuizzyBackendException: $message';
  }
}
