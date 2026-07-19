class DeckGenerationException implements Exception {
  final String message;

  DeckGenerationException(this.message);

  @override
  String toString() {
    return "DeckGenerationException: $message";
  }
}
