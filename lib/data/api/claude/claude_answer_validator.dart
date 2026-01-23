import 'package:poc_ai_quiz/data/api/claude/claude_api_service.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_request_models.dart'
    as request;
import 'package:poc_ai_quiz/data/api/claude/claude_response_models.dart'
    as response;
import 'package:poc_ai_quiz/data/api/gemini_ai/quiz_score_model.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class ClaudeAnswerValidator extends IAnswerValidator {
  static final _logger = Logger.withTag('ClaudeAnswerValidator');

  final ClaudeApiService _apiService;
  final String _model;

  ClaudeAnswerValidator(
    this._apiService, {
    String model = 'claude-3-5-haiku-20241022',
  }) : _model = model;

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    try {
      _logger.d('Validating answer with Claude');
      _logger.v('Question: $question');
      _logger.v('Expected answer: $correctAnswer');
      _logger.v('User answer: $userAnswer');

      final basePrompt = buildValidationPrompt(
        question: question,
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
      );

      final prompt = """
$basePrompt

Please use the record_quiz_score tool to provide your evaluation.
""";

      // Define the tool schema for structured output
      final tools = [
        request.Tool(
          name: 'record_quiz_score',
          description: 'Record the quiz score evaluation with detailed breakdown',
          inputSchema: {
            'type': 'object',
            'properties': {
              'score': {
                'type': 'integer',
                'description': 'Score between 0 and 100',
                'minimum': 0,
                'maximum': 100,
              },
              'explanation': {
                'type': 'string',
                'description': 'Brief explanation (1-2 sentences)',
              },
              'correctPoints': {
                'type': 'array',
                'description': 'Key points that were correctly addressed',
                'items': {'type': 'string'},
              },
              'missingPoints': {
                'type': 'array',
                'description': 'Key points that were missing or incorrect',
                'items': {'type': 'string'},
              },
            },
            'required': ['score', 'explanation', 'correctPoints', 'missingPoints'],
          },
        ),
      ];

      final claudeRequest = request.ClaudeRequest(
        model: _model,
        messages: [
          request.Message(
            role: 'user',
            content: prompt,
          ),
        ],
        maxTokens: 1024,
        temperature: 0.3,
        tools: tools,
        toolChoice: {'type': 'tool', 'name': 'record_quiz_score'},
      );

      _logger.d('Sending request to Claude API');
      final apiResponse = await _apiService.createMessage(
        body: claudeRequest.toJson(),
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('Claude API request failed');
        throw Exception('Failed to validate answer: ${apiResponse.error}');
      }

      final claudeResponse = response.ClaudeResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (claudeResponse.content == null || claudeResponse.content!.isEmpty) {
        _logger.e('No content in Claude response');
        throw Exception('No content in Claude response');
      }

      // Find the tool_use content block
      final toolUseContent = claudeResponse.content!.firstWhere(
        (content) => content.type == 'tool_use',
        orElse: () => throw Exception('No tool_use block in Claude response'),
      );

      if (toolUseContent.input == null) {
        _logger.e('No input in tool_use content');
        throw Exception('No tool input in Claude response');
      }

      final toolInput = toolUseContent.input!;
      _logger.d('Received tool response from Claude: $toolInput');

      // Parse the tool input as QuizScore
      final quizScore = QuizScore.fromJson(toolInput);

      _logger.i('Validation score: ${quizScore.score}');
      _logger.d('Explanation: ${quizScore.explanation}');
      _logger.v('Correct points: ${quizScore.correctPoints}');
      _logger.v('Missing points: ${quizScore.missingPoints}');

      return AnswerResult(
        score: quizScore.score / 100.0,
        explanation: quizScore.explanation,
      );
    } catch (e, stackTrace) {
      _logger.e('Error validating answer with Claude',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}