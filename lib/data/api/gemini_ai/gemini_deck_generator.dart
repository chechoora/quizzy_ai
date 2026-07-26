import 'dart:convert';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_request_models.dart'
    as gemini_request;
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_response_models.dart'
    as gemini_response;
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/deck_gen_prompts.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/ai_gen/model/generated_deck.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class GeminiDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('GeminiDeckGenerator');

  final GeminiApiService _apiService;
  final ValidatorConfigProvider _configProvider;

  GeminiDeckGenerator(
    this._apiService,
    this._configProvider,
  );

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.i('Generating deck with Gemini AI');
      _logger.v('Prompt: ${request.prompt}');

      final config = _configProvider.geminiConfig;
      if (config == null || config is! ApiKeyConfig) {
        throw DeckGenerationException('Gemini configuration not found');
      }

      if (!config.isValid) {
        throw DeckGenerationException(
            'Invalid Gemini configuration: API key or model is empty');
      }

      final model = config.model;
      _logger.d('Using Gemini model: $model');

      final prompt = '''
${DeckGenPrompts.geminiLanguageInstruction}

${buildGenerationPrompt(request)}

${DeckGenPrompts.geminiGenerateInstruction}
''';

      final geminiRequest = gemini_request.GeminiRequest(
        contents: [
          gemini_request.Content(
            parts: [gemini_request.Part(text: prompt)],
          ),
        ],
        generationConfig: gemini_request.GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 4000,
          topP: 0.95,
          topK: 40,
          responseMimeType: 'application/json',
          responseSchema: DeckGenPrompts.deckSchema,
        ),
      );

      _logger.d('Sending request to Gemini API');
      final apiResponse = await _apiService.generateContent(
        body: geminiRequest.toJson(),
        model: model,
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('Gemini API request failed');
        throw DeckGenerationException(
            'Failed to generate deck: ${apiResponse.error}');
      }

      final geminiResponse = gemini_response.GeminiResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (geminiResponse.candidates == null ||
          geminiResponse.candidates!.isEmpty) {
        _logger.e('No candidates in Gemini response');
        throw DeckGenerationException('No response candidates from Gemini');
      }

      final candidate = geminiResponse.candidates!.first;
      if (candidate.content == null ||
          candidate.content!.parts == null ||
          candidate.content!.parts!.isEmpty) {
        _logger.e('No content in Gemini candidate');
        throw DeckGenerationException('No content in Gemini response');
      }

      final text = candidate.content!.parts!.first.text ?? '';
      _logger.d('Received response from Gemini: $text');

      final jsonResponse = jsonDecode(text) as Map<String, dynamic>;
      final deck = GeneratedDeck.fromJson(jsonResponse);

      _logger.i('Generated ${deck.cards.length} cards');
      return deck.toPlainDeck();
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with Gemini',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
