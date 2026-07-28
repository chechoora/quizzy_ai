import 'package:poc_ai_quiz/data/api/claude/claude_api_service.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_request_models.dart'
    as claude_request;
import 'package:poc_ai_quiz/data/api/claude/claude_response_models.dart'
    as claude_response;
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/deck_gen_prompts.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/ai_gen/model/generated_deck.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class ClaudeDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('ClaudeDeckGenerator');

  final ClaudeApiService _apiService;
  final ValidatorConfigProvider _configProvider;

  ClaudeDeckGenerator(
    this._apiService,
    this._configProvider,
  );

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.i('Generating deck with Claude');
      _logger.v('Prompt: ${request.prompt}');

      final config = _configProvider.claudeConfig;
      if (config == null || config is! ApiKeyConfig) {
        throw DeckGenerationConfigException('Claude configuration not found');
      }

      if (!config.isValid) {
        throw DeckGenerationConfigException(
            'Invalid Claude configuration: API key or model is empty');
      }

      final model = config.model;
      _logger.d('Using Claude model: $model');

      final prompt = '''
${buildGenerationPrompt(request)}

${DeckGenPrompts.claudeToolUseInstruction}
''';

      // Define the tool schema for structured output using shared schema
      final tools = [
        claude_request.Tool(
          name: 'record_deck',
          description: 'Record the generated deck of study cards',
          inputSchema: DeckGenPrompts.deckSchema,
        ),
      ];

      final claudeRequest = claude_request.ClaudeRequest(
        model: model,
        messages: [
          claude_request.Message(
            role: 'user',
            content: prompt,
          ),
        ],
        maxTokens: 4000,
        temperature: 0.7,
        tools: tools,
        toolChoice: {'type': 'tool', 'name': 'record_deck'},
      );

      _logger.d('Sending request to Claude API');
      final apiResponse = await _apiService.createMessage(
        body: claudeRequest.toJson(),
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('Claude API request failed');
        throw DeckGenerationException(
            'Failed to generate deck: ${apiResponse.error}');
      }

      final claudeResponse = claude_response.ClaudeResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (claudeResponse.content == null || claudeResponse.content!.isEmpty) {
        _logger.e('No content in Claude response');
        throw DeckGenerationException('No content in Claude response');
      }

      // Find the tool_use content block
      final toolUseContent = claudeResponse.content!.firstWhere(
        (content) => content.type == 'tool_use',
        orElse: () =>
            throw DeckGenerationException('No tool_use block in Claude response'),
      );

      if (toolUseContent.input == null) {
        _logger.e('No input in tool_use content');
        throw DeckGenerationException('No tool input in Claude response');
      }

      final toolInput = toolUseContent.input!;
      _logger.d('Received tool response from Claude: $toolInput');

      final deck = GeneratedDeck.fromJson(toolInput);

      _logger.i('Generated ${deck.cards.length} cards');
      return deck.toPlainDeck();
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with Claude',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
