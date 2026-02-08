import 'dart:convert';
import 'package:poc_ai_quiz/data/api/openai/openai_api_service.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_request_models.dart'
    as request;
import 'package:poc_ai_quiz/data/api/openai/openai_response_models.dart'
    as response;
import 'package:poc_ai_quiz/data/api/gemini_ai/quiz_score_model.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/validator_prompts.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class OpenAIAnswerValidator extends IAnswerValidator {
  static final _logger = Logger.withTag('OpenAIAnswerValidator');

  final OpenAIApiService _apiService;
  final String _model;

  OpenAIAnswerValidator(
    this._apiService, {
    String model = 'gpt-4o-mini',
  }) : _model = model;

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    try {
      _logger.d('Validating answer with OpenAI');
      _logger.v('Expected answer: $correctAnswer');
      _logger.v('User answer: $userAnswer');

      final basePrompt = buildValidationPrompt(
        question: question,
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
      );

      final prompt = '''
$basePrompt

${ValidatorPrompts.jsonResponseInstruction}
''';

      final openAIRequest = request.OpenAIRequest(
        model: _model,
        messages: [
          request.Message(
            role: 'user',
            content: prompt,
          ),
        ],
        temperature: 0.3,
        maxTokens: 500,
        topP: 0.95,
        responseFormat: {
          'type': 'json_schema',
          'json_schema': {
            'name': 'quiz_score',
            'strict': true,
            'schema': {
              ...ValidatorPrompts.quizScoreSchema,
              'additionalProperties': false,
            },
          },
        },
      );

      _logger.d('Sending request to OpenAI API');
      final apiResponse = await _apiService.createChatCompletion(
        body: openAIRequest.toJson(),
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('OpenAI API request failed');
        throw Exception('Failed to validate answer: ${apiResponse.error}');
      }

      final openAIResponse = response.OpenAIResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (openAIResponse.choices == null || openAIResponse.choices!.isEmpty) {
        _logger.e('No choices in OpenAI response');
        throw Exception('No response choices from OpenAI');
      }

      final choice = openAIResponse.choices!.first;
      if (choice.message == null || choice.message!.content == null) {
        _logger.e('No content in OpenAI choice');
        throw Exception('No content in OpenAI response');
      }

      final content = choice.message!.content!;
      _logger.d('Received response from OpenAI: $content');

      // Parse the JSON response
      final jsonResponse = jsonDecode(content) as Map<String, dynamic>;
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
    } catch (e, stackTrace) {
      _logger.e('Error validating answer with OpenAI',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
