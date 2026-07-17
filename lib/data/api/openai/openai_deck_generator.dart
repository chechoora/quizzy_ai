import 'dart:convert';
import 'package:poc_ai_quiz/data/api/openai/openai_api_service.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_request_models.dart'
    as openai_request;
import 'package:poc_ai_quiz/data/api/openai/openai_response_models.dart'
    as openai_response;
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/deck_gen_prompts.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/ai_gen/model/generated_deck.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class OpenAIDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('OpenAIDeckGenerator');

  final OpenAIApiService _apiService;
  final ValidatorConfigProvider _configProvider;

  OpenAIDeckGenerator(
    this._apiService,
    this._configProvider,
  );

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.d('Generating deck with OpenAI');
      _logger.v('Prompt: ${request.prompt}');

      final config = _configProvider.openAiConfig;
      if (config == null || config is! ApiKeyConfig) {
        throw DeckGenerationException('OpenAI configuration not found');
      }

      if (!config.isValid) {
        throw DeckGenerationException(
            'Invalid OpenAI configuration: API key or model is empty');
      }

      final model = config.model;
      _logger.d('Using OpenAI model: $model');

      final prompt = '''
${buildGenerationPrompt(request)}

${DeckGenPrompts.jsonResponseInstruction}
''';

      final openAIRequest = openai_request.OpenAIRequest(
        model: model,
        messages: [
          openai_request.Message(
            role: 'user',
            content: prompt,
          ),
        ],
        temperature: 0.7,
        maxTokens: 4000,
        topP: 0.95,
        responseFormat: {
          'type': 'json_schema',
          'json_schema': {
            'name': 'generated_deck',
            'strict': true,
            'schema': DeckGenPrompts.strictDeckSchema,
          },
        },
      );

      _logger.d('Sending request to OpenAI API');
      final apiResponse = await _apiService.createChatCompletion(
        body: openAIRequest.toJson(),
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('OpenAI API request failed');
        throw DeckGenerationException(
            'Failed to generate deck: ${apiResponse.error}');
      }

      final openAIResponse = openai_response.OpenAIResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (openAIResponse.choices == null || openAIResponse.choices!.isEmpty) {
        _logger.e('No choices in OpenAI response');
        throw DeckGenerationException('No response choices from OpenAI');
      }

      final choice = openAIResponse.choices!.first;
      if (choice.message == null || choice.message!.content == null) {
        _logger.e('No content in OpenAI choice');
        throw DeckGenerationException('No content in OpenAI response');
      }

      final content = choice.message!.content!;
      _logger.d('Received response from OpenAI: $content');

      final jsonResponse = jsonDecode(content) as Map<String, dynamic>;
      final deck = GeneratedDeck.fromJson(jsonResponse);

      _logger.i('Generated ${deck.cards.length} cards');
      return deck.toPlainDeck();
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with OpenAI',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
