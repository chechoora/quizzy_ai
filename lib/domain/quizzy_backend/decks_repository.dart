import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/decks_api_service.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/batch_delete_cards_result.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/batch_update_cards_result.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/generated_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/new_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_update.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck_with_cards.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Remote deck/card CRUD against the quizzy-ai-pro-be backend.
class DecksRepository {
  DecksRepository({
    required this.apiService,
    required this.logger,
  });

  final DecksApiService apiService;
  final Logger logger;

  Future<GeneratedRemoteDeck> generateDeck({
    required String prompt,
    String? deckTitle,
    List<RemoteCardDraft>? currentCards,
  }) async {
    logger.d('generateDeck: prompt=$prompt, deckTitle=$deckTitle');
    try {
      final response = await apiService.generateDeck(
        body: GenerateDeckDto(
          prompt: prompt,
          deckTitle: deckTitle,
          currentCards:
              currentCards?.map((c) => CardDto(question: c.question, answer: c.answer)).toList(),
        ),
      );
      final dto = _requireBody(response, 'generateDeck');
      final parsed =
          GenerateDeckResponseDto.fromJson(dto as Map<String, dynamic>);
      logger.i('generateDeck: success, ${parsed.cards.length} cards');
      return GeneratedRemoteDeck(
        cards: parsed.cards
            .map((c) => RemoteCardDraft(question: c.question, answer: c.answer))
            .toList(),
        notice: parsed.notice,
      );
    } catch (e, stackTrace) {
      logger.e('generateDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<List<RemoteDeck>> listDecks() async {
    logger.d('listDecks: starting');
    try {
      final response = await apiService.listDecks();
      final body = _requireBody(response, 'listDecks');
      final decks = (body as List)
          .map((d) => _toRemoteDeck(
              DeckResponseDto.fromJson(d as Map<String, dynamic>)))
          .toList();
      logger.i('listDecks: success, ${decks.length} decks');
      return decks;
    } catch (e, stackTrace) {
      logger.e('listDecks: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<RemoteDeckWithCards> createDeck(NewRemoteDeck deck) async {
    logger.d('createDeck: title=${deck.title}');
    try {
      final response = await apiService.createDeck(
        body: CreateDeckDto(
          title: deck.title,
          cards: deck.cards
              ?.map((c) => CardDto(question: c.question, answer: c.answer))
              .toList(),
        ),
      );
      final body = _requireBody(response, 'createDeck');
      final result = _toRemoteDeckWithCards(
          DeckWithCardsResponseDto.fromJson(body as Map<String, dynamic>));
      logger.d('createDeck: success, id=${result.id}');
      return result;
    } catch (e, stackTrace) {
      logger.e('createDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<List<RemoteDeckWithCards>> createDecks(
      List<NewRemoteDeck> decks) async {
    logger.d('createDecks: count=${decks.length}');
    try {
      final response = await apiService.createDecks(
        body: decks
            .map((deck) => CreateDeckDto(
                  title: deck.title,
                  cards: deck.cards
                      ?.map((c) =>
                          CardDto(question: c.question, answer: c.answer))
                      .toList(),
                ))
            .toList(),
      );
      final body = _requireBody(response, 'createDecks');
      final results = (body as List)
          .map((d) => _toRemoteDeckWithCards(
              DeckWithCardsResponseDto.fromJson(d as Map<String, dynamic>)))
          .toList();
      logger.i('createDecks: success, ${results.length} decks created');
      return results;
    } catch (e, stackTrace) {
      logger.e('createDecks: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<RemoteDeckWithCards> getDeck(String id) async {
    logger.d('getDeck: id=$id');
    try {
      final response = await apiService.getDeck(id: id);
      final body = _requireBody(response, 'getDeck');
      final result = _toRemoteDeckWithCards(
          DeckWithCardsResponseDto.fromJson(body as Map<String, dynamic>));
      logger.i('getDeck: success, id=$id');
      return result;
    } catch (e, stackTrace) {
      logger.e('getDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<RemoteDeck> updateDeck(
    String id, {
    String? title,
    bool? isArchived,
  }) async {
    logger.d('updateDeck: id=$id, title=$title, isArchived=$isArchived');
    try {
      final response = await apiService.updateDeck(
        id: id,
        body: UpdateDeckDto(title: title, isArchived: isArchived),
      );
      final body = _requireBody(response, 'updateDeck');
      final result = _toRemoteDeck(
          DeckResponseDto.fromJson(body as Map<String, dynamic>));
      logger.d('updateDeck: success, id=$id');
      return result;
    } catch (e, stackTrace) {
      logger.e('updateDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteDeck(String id) async {
    logger.d('deleteDeck: id=$id');
    try {
      final response = await apiService.deleteDeck(id: id);
      if (!response.isSuccessful) {
        throw QuizzyBackendException(
            'Failed to delete deck: ${response.statusCode}, ${response.error}',
            statusCode: response.statusCode,
            retryAfter: _retryAfterFrom(response));
      }
      logger.d('deleteDeck: success, id=$id');
    } catch (e, stackTrace) {
      logger.e('deleteDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<List<RemoteCard>> listCards(String deckId) async {
    logger.d('listCards: deckId=$deckId');
    try {
      final response = await apiService.listCards(id: deckId);
      final body = _requireBody(response, 'listCards');
      final cards = (body as List)
          .map((c) => _toRemoteCard(
              CardResponseDto.fromJson(c as Map<String, dynamic>)))
          .toList();
      logger.d('listCards: success, ${cards.length} cards');
      return cards;
    } catch (e, stackTrace) {
      logger.e('listCards: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<List<RemoteCard>> addCards(
    String deckId,
    List<RemoteCardDraft> cards,
  ) async {
    logger.d('addCards: deckId=$deckId, count=${cards.length}');
    try {
      final response = await apiService.addCards(
        id: deckId,
        body: cards.map((c) => CardDto(question: c.question, answer: c.answer)).toList(),
      );
      final body = _requireBody(response, 'addCards');
      final results = (body as List)
          .map((c) => _toRemoteCard(
              CardResponseDto.fromJson(c as Map<String, dynamic>)))
          .toList();
      logger.d('addCards: success, ${results.length} cards added');
      return results;
    } catch (e, stackTrace) {
      logger.e('addCards: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<BatchUpdateCardsResult> updateCards(
    String deckId,
    List<RemoteCardUpdate> items,
  ) async {
    logger.d('updateCards: deckId=$deckId, count=${items.length}');
    try {
      final response = await apiService.updateCards(
        id: deckId,
        body: items
            .map((i) => UpdateCardBatchItemDto(
                  id: i.remoteId,
                  question: i.question,
                  answer: i.answer,
                  isArchived: i.isArchived,
                ))
            .toList(),
      );
      final body = _requireBody(response, 'updateCards');
      final parsed =
          BatchUpdateCardsResponseDto.fromJson(body as Map<String, dynamic>);
      final result = BatchUpdateCardsResult(
        updated: parsed.updated.map(_toRemoteCard).toList(),
        notFound: parsed.notFound,
      );
      logger.d('updateCards: success, ${result.updated.length} updated, '
          '${result.notFound.length} notFound');
      return result;
    } catch (e, stackTrace) {
      logger.e('updateCards: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<BatchDeleteCardsResult> deleteCards(
    String deckId,
    List<String> ids,
  ) async {
    logger.d('deleteCards: deckId=$deckId, count=${ids.length}');
    try {
      final response = await apiService.deleteCards(
        id: deckId,
        body: BatchDeleteCardsDto(ids: ids),
      );
      final body = _requireBody(response, 'deleteCards');
      final parsed =
          BatchDeleteCardsResponseDto.fromJson(body as Map<String, dynamic>);
      final result = BatchDeleteCardsResult(
        deleted: parsed.deleted,
        notFound: parsed.notFound,
      );
      logger.d('deleteCards: success, ${result.deleted.length} deleted, '
          '${result.notFound.length} notFound');
      return result;
    } catch (e, stackTrace) {
      logger.e('deleteCards: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  dynamic _requireBody(Response response, String operation) {
    if (!response.isSuccessful || response.body == null) {
      throw QuizzyBackendException(
        'Failed to $operation: ${response.statusCode}, ${response.error}',
        statusCode: response.statusCode,
        retryAfter: _retryAfterFrom(response),
      );
    }
    return response.body;
  }

  /// Parses the `Retry-After` response header (seconds form only) so
  /// [SyncScheduler] can size its 429 backoff window. Header lookup is
  /// case-insensitive since the underlying `http` client doesn't guarantee
  /// casing is preserved.
  Duration? _retryAfterFrom(Response response) {
    String? raw;
    for (final entry in response.base.headers.entries) {
      if (entry.key.toLowerCase() == 'retry-after') {
        raw = entry.value;
        break;
      }
    }
    final seconds = raw == null ? null : int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  RemoteDeck _toRemoteDeck(DeckResponseDto dto) => RemoteDeck(
        id: dto.id,
        userId: dto.userId,
        title: dto.title,
        isArchived: dto.isArchived,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        lastActivityAt: dto.lastActivityAt,
        stats: _toItemStats(dto.stats),
      );

  RemoteCard _toRemoteCard(CardResponseDto dto) => RemoteCard(
        id: dto.id,
        deckId: dto.deckId,
        question: dto.question,
        answer: dto.answer,
        isArchived: dto.isArchived,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        stats: _toItemStats(dto.stats),
      );

  RemoteDeckWithCards _toRemoteDeckWithCards(DeckWithCardsResponseDto dto) =>
      RemoteDeckWithCards(
        id: dto.id,
        userId: dto.userId,
        title: dto.title,
        isArchived: dto.isArchived,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        cards: dto.cards.map(_toRemoteCard).toList(),
        stats: _toItemStats(dto.stats),
      );

  ItemStats? _toItemStats(StatsDto? dto) {
    if (dto == null) return null;
    return ItemStats(
      accuracy: PeriodStats(
        week: dto.accuracy.week,
        month: dto.accuracy.month,
        year: dto.accuracy.year,
      ),
      attempts: PeriodStats(
        week: dto.attempts.week,
        month: dto.attempts.month,
        year: dto.attempts.year,
      ),
      bestStreak: PeriodStats(
        week: dto.bestStreak.week,
        month: dto.bestStreak.month,
        year: dto.bestStreak.year,
      ),
      lastPlayedAt: dto.lastPlayedAt,
    );
  }
}
