import 'dart:convert';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_request_models.dart'
    as request;
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_response_models.dart'
    as response;
import 'package:poc_ai_quiz/data/api/gemini_ai/quiz_score_model.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class GeminiAnswerValidator extends IAnswerValidator {
  static final _logger = Logger.withTag('GeminiAnswerValidator');

  final GeminiApiService _apiService;

  GeminiAnswerValidator(this._apiService);

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    try {
      _logger.d('Validating answer with Gemini AI');
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

Please evaluate how well the user answer matches the expected answer.
""";

      // Define JSON schema for structured output
      final responseSchema = {
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
                'Brief explanation of why this score was given (1-2 sentences) in the language of the question',
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
      };

      final geminiRequest = request.GeminiRequest(
        contents: [
          request.Content(
            parts: [request.Part(text: prompt)],
          ),
        ],
        generationConfig: request.GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 500,
          topP: 0.95,
          topK: 40,
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
        ),
      );

      _logger.d('Sending request to Gemini API');
      final apiResponse = await _apiService.generateContent(
        body: geminiRequest.toJson(),
      );

      if (!apiResponse.isSuccessful || apiResponse.body == null) {
        _logger.e('Gemini API request failed');
        throw Exception('Failed to validate answer: ${apiResponse.error}');
      }

      final geminiResponse = response.GeminiResponse.fromJson(
          apiResponse.body as Map<String, dynamic>);

      if (geminiResponse.candidates == null ||
          geminiResponse.candidates!.isEmpty) {
        _logger.e('No candidates in Gemini response');
        throw Exception('No response candidates from Gemini');
      }

      final candidate = geminiResponse.candidates!.first;
      if (candidate.content == null ||
          candidate.content!.parts == null ||
          candidate.content!.parts!.isEmpty) {
        _logger.e('No content in Gemini candidate');
        throw Exception('No content in Gemini response');
      }

      final text = candidate.content!.parts!.first.text ?? '';
      _logger.d('Received response from Gemini: $text');

      // Parse the structured JSON response
      final jsonResponse = jsonDecode(text) as Map<String, dynamic>;
      final quizScore = QuizScore.fromJson(jsonResponse);

      _logger.i('Validation score: ${quizScore.score}');
      _logger.d('Explanation: ${quizScore.explanation}');
      _logger.v('Correct points: ${quizScore.correctPoints}');
      _logger.v('Missing points: ${quizScore.missingPoints}');

      return AnswerResult(
        score: quizScore.score / 100.0,
        explanation: quizScore.explanation,
      );
    } catch (e, stackTrace) {
      _logger.e('Error validating answer with Gemini',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
