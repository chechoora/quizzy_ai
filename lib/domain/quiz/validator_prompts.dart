/// Prompt and schema constants used by answer validators.
///
/// This file contains shared prompt and schema constants to avoid duplication
/// across different AI validator implementations.
abstract class ValidatorPrompts {
  // ========== Response Schema Constants ==========

  /// Base JSON schema for quiz score response.
  /// Used by Gemini, OpenAI, and Claude validators.
  static const Map<String, dynamic> quizScoreSchema = {
    'type': 'object',
    'properties': {
      'score': {
        'type': 'integer',
        'description':
            'Score between 0 and 100 indicating how well the user answer matches the expected answer',
        'minimum': 0,
        'maximum': 100,
      },
      'explanation': {
        'type': 'string',
        'description':
            'Brief explanation (1-5 sentences) in the language of the question',
      },
      'correctPoints': {
        'type': 'array',
        'description':
            'Key points that were correctly addressed in the same language as the question',
        'items': {'type': 'string'},
      },
      'missingPoints': {
        'type': 'array',
        'description':
            'Key points that were missing or incorrect in the same language as the question',
        'items': {'type': 'string'},
      },
    },
    'required': ['score', 'explanation', 'correctPoints', 'missingPoints'],
  };

  /// Required fields for quiz score schema.
  static const List<String> quizScoreRequiredFields = [
    'score',
    'explanation',
    'correctPoints',
    'missingPoints',
  ];

  // ========== Prompt Constants ==========
  /// JSON response format instruction shared by OpenAI and Ollama validators.
  static const String jsonResponseInstruction = '''
Please evaluate how well the user answer matches the expected answer and respond with a JSON object containing:
- score: integer between 0 and 100
- explanation: brief explanation (1-2 sentences) in the language of the question
- correctPoints: array of key points that were correctly addressed
- missingPoints: array of key points that were missing or incorrect''';

  /// Additional instruction for Ollama to ensure JSON-only response.
  static const String jsonOnlyInstruction =
      'Respond ONLY with the JSON object, no additional text.';

  /// Instruction for Claude to use the record_quiz_score tool.
  static const String claudeToolUseInstruction =
      'Please use the record_quiz_score tool to provide your evaluation.';

  /// Language instruction prefix for Gemini to respond in question's language.
  static const String geminiLanguageInstruction =
      'CRITICAL INSTRUCTION: All text responses (explanation, correctPoints, missingPoints) MUST be written in the same language as the question below. Do NOT respond in English unless the question is in English.';

  /// Simple evaluation instruction for Gemini.
  static const String geminiEvaluateInstruction =
      'Please evaluate how well the user answer matches the expected answer.';

  /// Instruction to respond in the same language as the question.
  static const String answerInQuestionLanguage =
      'Answer values must be provided in the SAME LANGUAGE as the question.';
}
