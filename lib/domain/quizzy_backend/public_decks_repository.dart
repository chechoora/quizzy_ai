import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/public_decks_api_service.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_category.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_detail.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_page.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_summary.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_tag.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck_with_cards.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Browsing/searching public decks and copying one into the current user's
/// own decks, against the quizzy-ai-pro-be backend.
class PublicDecksRepository {
  PublicDecksRepository({
    required this.apiService,
    required this.logger,
  });

  final PublicDecksApiService apiService;
  final Logger logger;

  Future<List<PublicCategory>> listCategories() async {
    logger.d('listCategories: starting');
    try {
      final response = await apiService.listCategories();
      final body = _requireBody(response, 'listCategories');
      final categories = (body as List)
          .map((c) => _toPublicCategory(
              PublicCategoryDto.fromJson(c as Map<String, dynamic>)))
          .toList();
      logger.i('listCategories: success, ${categories.length} categories');
      return categories;
    } catch (e, stackTrace) {
      logger.e('listCategories: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<PublicDeckPage> listPublicDecks({
    String? category,
    String? tag,
    String? q,
    String? cursor,
    int? limit,
  }) async {
    logger.d(
        'listPublicDecks: category=$category, tag=$tag, q=$q, cursor=$cursor, limit=$limit');
    try {
      final response = await apiService.listDecks(
        category: category,
        tag: tag,
        q: q,
        cursor: cursor,
        limit: limit,
      );
      final body = _requireBody(response, 'listPublicDecks');
      final page = _toPublicDeckPage(
          PublicDeckPageDto.fromJson(body as Map<String, dynamic>));
      logger.i(
          'listPublicDecks: success, ${page.items.length} decks, hasMore=${page.hasMore}');
      return page;
    } catch (e, stackTrace) {
      logger.e('listPublicDecks: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<PublicDeckDetail> getPublicDeck(String id) async {
    logger.d('getPublicDeck: id=$id');
    try {
      final response = await apiService.getDeck(id: id);
      final body = _requireBody(response, 'getPublicDeck');
      final deck = _toPublicDeckDetail(
          PublicDeckDetailDto.fromJson(body as Map<String, dynamic>));
      logger.i('getPublicDeck: success, id=$id');
      return deck;
    } catch (e, stackTrace) {
      logger.e('getPublicDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<RemoteDeckWithCards> copyPublicDeck(String id) async {
    logger.d('copyPublicDeck: id=$id');
    try {
      final response = await apiService.copyDeck(id: id);
      final body = _requireBody(response, 'copyPublicDeck');
      final result = _toRemoteDeckWithCards(
          DeckWithCardsResponseDto.fromJson(body as Map<String, dynamic>));
      logger.i('copyPublicDeck: success, id=$id, newDeckId=${result.id}');
      return result;
    } catch (e, stackTrace) {
      logger.e('copyPublicDeck: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  dynamic _requireBody(Response response, String operation) {
    if (!response.isSuccessful || response.body == null) {
      throw QuizzyBackendException(
          'Failed to $operation: ${response.statusCode}, ${response.error}',
          statusCode: response.statusCode);
    }
    return response.body;
  }

  PublicTag _toPublicTag(PublicTagDto dto) => PublicTag(
        slug: dto.slug,
        name: dto.name,
      );

  PublicCategory _toPublicCategory(PublicCategoryDto dto) => PublicCategory(
        id: dto.id,
        slug: dto.slug,
        name: dto.name,
        description: dto.description,
        deckCount: dto.deckCount,
      );

  PublicDeckSummary _toPublicDeckSummary(PublicDeckSummaryDto dto) =>
      PublicDeckSummary(
        id: dto.id,
        categoryId: dto.categoryId,
        title: dto.title,
        description: dto.description,
        tags: dto.tags.map(_toPublicTag).toList(),
        cardCount: dto.cardCount,
      );

  PublicDeckPage _toPublicDeckPage(PublicDeckPageDto dto) => PublicDeckPage(
        items: dto.items.map(_toPublicDeckSummary).toList(),
        nextCursor: dto.nextCursor,
        hasMore: dto.hasMore,
      );

  PublicCard _toPublicCard(PublicCardDto dto) => PublicCard(
        id: dto.id,
        question: dto.question,
        answer: dto.answer,
        position: dto.position,
      );

  PublicDeckDetail _toPublicDeckDetail(PublicDeckDetailDto dto) =>
      PublicDeckDetail(
        id: dto.id,
        categoryId: dto.categoryId,
        title: dto.title,
        description: dto.description,
        tags: dto.tags.map(_toPublicTag).toList(),
        cardCount: dto.cardCount,
        cards: dto.cards.map(_toPublicCard).toList(),
      );

  RemoteCard _toRemoteCard(CardResponseDto dto) => RemoteCard(
        id: dto.id,
        deckId: dto.deckId,
        question: dto.question,
        answer: dto.answer,
        isArchived: dto.isArchived,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
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
      );
}
