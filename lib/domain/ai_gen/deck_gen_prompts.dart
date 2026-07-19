/// Prompt and schema constants used by deck generators.
///
/// This file contains shared prompt and schema constants to avoid duplication
/// across different AI deck generator implementations.
abstract class DeckGenPrompts {
  // ========== Response Schema Constants ==========

  /// Schema of a single card. Built by [_buildDeckSchema] into [deckSchema].
  static const Map<String, dynamic> _cardProperties = {
    'question': {
      'type': 'string',
      'description':
          'The prompt side of the card, in the language of the user request',
    },
    'answer': {
      'type': 'string',
      'description':
          'The answer side of the card, in the language of the user request',
    },
  };

  static const Map<String, dynamic> _deckProperties = {
    'title': {
      'type': 'string',
      'description':
          'Short deck title in the language of the user request (3-6 words)',
    },
  };

  /// OpenAI's `strict: true` requires `additionalProperties: false` on every
  /// object level, while Gemini's `responseSchema` rejects the keyword
  /// outright — hence [strict].
  static Map<String, dynamic> _buildDeckSchema({required bool strict}) => {
        'type': 'object',
        'properties': {
          ..._deckProperties,
          'cards': {
            'type': 'array',
            'description': 'The study cards making up the deck',
            'items': {
              'type': 'object',
              'properties': _cardProperties,
              'required': ['question', 'answer'],
              if (strict) 'additionalProperties': false,
            },
          },
        },
        'required': ['title', 'cards'],
        if (strict) 'additionalProperties': false,
      };

  /// Base JSON schema for a generated deck.
  /// Used by the Gemini and Claude deck generators.
  static Map<String, dynamic> get deckSchema => _buildDeckSchema(strict: false);

  /// [deckSchema] for OpenAI's `strict: true` structured outputs.
  static Map<String, dynamic> get strictDeckSchema =>
      _buildDeckSchema(strict: true);

  // ========== Prompt Constants ==========

  /// JSON response format instruction shared by OpenAI and Ollama generators.
  static const String jsonResponseInstruction = '''
Respond with a JSON object containing:
- title: a short deck title (3-6 words)
- cards: an array of objects, each with a "question" and an "answer" field''';

  /// Additional instruction for Ollama to ensure JSON-only response.
  static const String jsonOnlyInstruction =
      'Respond ONLY with the JSON object, no additional text.';

  /// Instruction for Claude to use the record_deck tool.
  static const String claudeToolUseInstruction =
      'Please use the record_deck tool to provide the deck.';

  /// Language instruction prefix for Gemini to respond in the request's
  /// language.
  static const String geminiLanguageInstruction =
      'CRITICAL INSTRUCTION: The title and every card question and answer MUST be written in the same language as the user request below. Do NOT respond in English unless the request is in English.';

  /// Simple generation instruction for Gemini.
  static const String geminiGenerateInstruction =
      'Please produce the deck of study cards described above.';
}
