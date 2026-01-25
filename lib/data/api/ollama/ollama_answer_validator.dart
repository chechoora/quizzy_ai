import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poc_ai_quiz/data/api/gemini_ai/quiz_score_model.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/validator_prompts.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class OllamaAnswerValidator extends IAnswerValidator {
  static final _logger = Logger.withTag('OllamaAnswerValidator');

  final ValidatorConfigProvider _configProvider;

  OllamaAnswerValidator(this._configProvider);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    try {
      _logger.d('Validating answer with Ollama');
      _logger.v('Expected answer: $correctAnswer');
      _logger.v('User answer: $userAnswer');

      final config = _configProvider.ollamaConfig;
      if (config == null || config is! OpenSourceConfig) {
        throw Exception('Ollama configuration not found');
      }

      if (!config.isValid) {
        throw Exception('Invalid Ollama configuration: URL or model is empty');
      }

      final basePrompt = buildValidationPrompt(
        question: question,
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
      );

      final prompt = '''
$basePrompt

${ValidatorPrompts.jsonResponseInstruction}

${ValidatorPrompts.jsonOnlyInstruction}''';

      // Build request for Ollama's OpenAI-compatible endpoint
      final requestBody = {
        'model': config.model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.3,
        'format': 'json',
        'stream': false,
      };

      final url = _buildUrl(config.url);
      _logger.d('Sending request to Ollama API at $url');

      final response = await http.post(
        Uri.parse('$url/api/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        _logger
            .e('Ollama API request failed with status ${response.statusCode}');
        throw Exception(
            'Failed to validate answer: ${response.statusCode} - ${response.body}');
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.d('Received response from Ollama');

      // Parse response - Ollama uses OpenAI-compatible format
      final choices = responseJson['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        // Try Ollama native format
        final message = responseJson['message'] as Map<String, dynamic>?;
        if (message == null) {
          _logger.e('No content in Ollama response');
          throw Exception('No content in Ollama response');
        }
        final content = message['content'] as String?;
        if (content == null) {
          _logger.e('No content in Ollama message');
          throw Exception('No content in Ollama message');
        }
        return _parseContent(content);
      }

      // OpenAI-compatible format
      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>?;
      if (message == null) {
        _logger.e('No message in Ollama choice');
        throw Exception('No message in Ollama response');
      }

      final content = message['content'] as String?;
      if (content == null) {
        _logger.e('No content in Ollama message');
        throw Exception('No content in Ollama message');
      }

      return _parseContent(content);
    } catch (e, stackTrace) {
      _logger.e('Error validating answer with Ollama',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  String _buildUrl(String baseUrl) {
    var normalizedUrl = baseUrl.trim();

    // Add http:// scheme if missing
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'http://$normalizedUrl';
    }

    // Remove trailing slash if present
    if (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
    }

    return normalizedUrl;
  }

  AnswerResult _parseContent(String content) {
    _logger.d('Parsing response content: $content');

    // Try to extract JSON from the content
    String jsonString = content.trim();

    // Handle markdown code blocks if present
    if (jsonString.startsWith('```json')) {
      jsonString = jsonString.substring(7);
    } else if (jsonString.startsWith('```')) {
      jsonString = jsonString.substring(3);
    }
    if (jsonString.endsWith('```')) {
      jsonString = jsonString.substring(0, jsonString.length - 3);
    }
    jsonString = jsonString.trim();

    final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;
    final quizScore = QuizScore.fromJson(jsonResponse);

    _logger.i('Validation score: ${quizScore.score}');
    _logger.d('Explanation: ${quizScore.explanation}');
    _logger.v('Correct points: ${quizScore.correctPoints}');
    _logger.v('Missing points: ${quizScore.missingPoints}');

    return AnswerResult(
      score: quizScore.score / 100.0,
      explanation: quizScore.explanation,
    );
  }
}
