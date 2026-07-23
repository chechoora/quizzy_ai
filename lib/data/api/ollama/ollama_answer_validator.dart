import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poc_ai_quiz/data/api/gemini_ai/quiz_score_model.dart';
import 'package:poc_ai_quiz/data/api/ollama/ollama_support.dart';
import 'package:poc_ai_quiz/domain/exception/answer_validator_exception.dart';
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
    String? cardId,
  }) async {
    try {
      _logger.d('Validating answer with Ollama');
      _logger.v('Expected answer: $correctAnswer');
      _logger.v('User answer: $userAnswer');

      final config = _configProvider.ollamaConfig;
      if (config == null || config is! OpenSourceConfig) {
        throw AnswerValidatorException('Ollama configuration not found');
      }

      if (!config.isValid) {
        throw AnswerValidatorException('Invalid Ollama configuration: URL or model is empty');
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

      final url = buildOllamaUrl(config.url);
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
        throw AnswerValidatorException(
            'Failed to validate answer: ${response.statusCode} - ${response.body}');
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.d('Received response from Ollama');

      final content = extractOllamaContent(responseJson);
      if (content == null) {
        _logger.e('No content in Ollama response');
        throw AnswerValidatorException('No content in Ollama response');
      }

      return _parseContent(correctAnswer, content);
    } catch (e, stackTrace) {
      _logger.e('Error validating answer with Ollama',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  AnswerResult _parseContent(String correctAnswer, String content) {
    _logger.d('Parsing response content: $content');

    final jsonResponse =
        jsonDecode(stripJsonFences(content)) as Map<String, dynamic>;
    final quizScore = QuizScore.fromJson(jsonResponse);

    _logger.i('Validation score: ${quizScore.score}');
    _logger.d('Explanation: ${quizScore.explanation}');
    _logger.v('Correct points: ${quizScore.correctPoints}');
    _logger.v('Missing points: ${quizScore.missingPoints}');

    return AnswerResult(
      correctAnswer: correctAnswer,
      score: quizScore.score / 100.0,
      explanation: quizScore.explanation,
    );
  }
}
