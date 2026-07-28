class DeckGenerationException implements Exception {
  final String message;

  DeckGenerationException(this.message);

  @override
  String toString() {
    return "DeckGenerationException: $message";
  }
}

/// Thrown when deck generation fails because the selected validator has no
/// (or an invalid) API key configured, as opposed to a generic generation
/// failure — lets callers offer a "go to settings" action instead of a plain
/// error.
class DeckGenerationConfigException extends DeckGenerationException {
  DeckGenerationConfigException(super.message);
}
