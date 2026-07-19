import 'package:poc_ai_quiz/data/api/quizzy_backend/cards_api_service.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Remote card editing/deletion against the quizzy-ai-pro-be backend.
class CardsRepository {
  CardsRepository({
    required this.apiService,
    required this.logger,
  });

  final CardsApiService apiService;
  final Logger logger;

  Future<RemoteCard> updateCard(
    String id, {
    String? question,
    String? answer,
    bool? isArchived,
  }) async {
    logger.d('updateCard: id=$id, question=$question, answer=$answer, isArchived=$isArchived');
    try {
      final response = await apiService.updateCard(
        id: id,
        body: UpdateCardDto(
          question: question,
          answer: answer,
          isArchived: isArchived,
        ),
      );
      if (!response.isSuccessful || response.body == null) {
        logger.e('updateCard: failed with status ${response.statusCode}');
        throw QuizzyBackendException(
            'Failed to update card: ${response.statusCode}, ${response.error}');
      }
      final dto =
          CardResponseDto.fromJson(response.body as Map<String, dynamic>);
      logger.i('updateCard: success, id=$id');
      return _toRemoteCard(dto);
    } catch (e, stackTrace) {
      logger.e('updateCard: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    logger.d('deleteCard: id=$id');
    try {
      final response = await apiService.deleteCard(id: id);
      if (!response.isSuccessful) {
        logger.e('deleteCard: failed with status ${response.statusCode}');
        throw QuizzyBackendException(
            'Failed to delete card: ${response.statusCode}, ${response.error}');
      }
      logger.i('deleteCard: success, id=$id');
    } catch (e, stackTrace) {
      logger.e('deleteCard: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  RemoteCard _toRemoteCard(CardResponseDto dto) => RemoteCard(
        id: dto.id,
        deckId: dto.deckId,
        question: dto.question,
        answer: dto.answer,
        isArchived: dto.isArchived,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );
}
