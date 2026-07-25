class QuizzyBackendException implements Exception {
  final String message;

  /// The HTTP status code that caused this exception, when known (e.g. used
  /// by the sync service to treat a 404 on a delete as "already gone").
  final int? statusCode;

  /// Parsed `Retry-After` response header (seconds form), when present on a
  /// 429 response. Used by [SyncScheduler] to size its backoff window.
  final Duration? retryAfter;

  QuizzyBackendException(this.message, {this.statusCode, this.retryAfter});

  @override
  String toString() {
    return 'QuizzyBackendException: $message';
  }
}
