import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poc_ai_quiz/data/api/ollama/ollama_support.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/deck_gen_prompts.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/ai_gen/model/generated_deck.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class OllamaDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('OllamaDeckGenerator');

  final ValidatorConfigProvider _configProvider;

  OllamaDeckGenerator(this._configProvider);

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.i('Generating deck with Ollama');
      _logger.v('Prompt: ${request.prompt}');

      final config = _configProvider.ollamaConfig;
      if (config == null || config is! OpenSourceConfig) {
        throw DeckGenerationException('Ollama configuration not found');
      }

      if (!config.isValid) {
        throw DeckGenerationException(
            'Invalid Ollama configuration: URL or model is empty');
      }

      final prompt = '''
${buildGenerationPrompt(request)}

${DeckGenPrompts.jsonResponseInstruction}

${DeckGenPrompts.jsonOnlyInstruction}''';

      final requestBody = {
        'model': config.model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
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
        throw DeckGenerationException(
            'Failed to generate deck: ${response.statusCode} - ${response.body}');
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.d('Received response from Ollama');

      final content = extractOllamaContent(responseJson);
      if (content == null) {
        _logger.e('No content in Ollama response');
        throw DeckGenerationException('No content in Ollama response');
      }

      _logger.d('Parsing response content: $content');
      final jsonResponse =
          jsonDecode(stripJsonFences(content)) as Map<String, dynamic>;
      final deck = GeneratedDeck.fromJson(jsonResponse);

      _logger.i('Generated ${deck.cards.length} cards');
      return deck.toPlainDeck();
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with Ollama',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
