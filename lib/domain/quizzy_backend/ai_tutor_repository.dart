import 'package:poc_ai_quiz/data/api/quizzy_backend/ai_tutor_api_service.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/answer_check_result.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// AI-powered answer checking against the quizzy-ai-pro-be backend.
class AiTutorRepository {
  AiTutorRepository({
    required this.apiService,
    required this.logger,
  });

  final AiTutorApiService apiService;
  final Logger logger;

  Future<AnswerCheckResult> checkAnswer({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    String? context,
    String? cardId,
  }) async {
    logger.d('checkAnswer: question=$question');
    try {
      final response = await apiService.checkAnswer(
        body: CheckAnswerDto(
          question: question,
          userAnswer: userAnswer,
          correctAnswer: correctAnswer,
          context: context,
          cardId: cardId,
        ),
      );
      if (!response.isSuccessful || response.body == null) {
        logger.e('checkAnswer: failed with status ${response.statusCode}');
        throw QuizzyBackendException(
            'Failed to check answer: ${response.statusCode}, ${response.error}');
      }
      final dto =
          AnswerResponseDto.fromJson(response.body as Map<String, dynamic>);
      logger.i('checkAnswer: success, isCorrect=${dto.isCorrect}');
      return AnswerCheckResult(
        isCorrect: dto.isCorrect,
        feedback: dto.feedback,
        confidence: dto.confidence,
        suggestions: dto.suggestions,
      );
    } catch (e, stackTrace) {
      logger.e('checkAnswer: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
