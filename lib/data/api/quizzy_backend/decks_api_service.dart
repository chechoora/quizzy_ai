import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';

part 'decks_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class DecksApiService extends ChopperService {
  static DecksApiService create([ChopperClient? client]) {
    final service = _$DecksApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Post(path: '/decks/generate')
  Future<Response> generateDeck({
    @Body() required GenerateDeckDto body,
  });

  @Get(path: '/decks')
  Future<Response> listDecks();

  @Post(path: '/decks')
  Future<Response> createDeck({
    @Body() required CreateDeckDto body,
  });

  @Post(path: '/decks/batch')
  Future<Response> createDecks({
    @Body() required List<CreateDeckDto> body,
  });

  @Get(path: '/decks/{id}')
  Future<Response> getDeck({
    @Path('id') required String id,
  });

  @Patch(path: '/decks/{id}')
  Future<Response> updateDeck({
    @Path('id') required String id,
    @Body() required UpdateDeckDto body,
  });

  @Delete(path: '/decks/{id}')
  Future<Response> deleteDeck({
    @Path('id') required String id,
  });

  @Get(path: '/decks/{id}/cards')
  Future<Response> listCards({
    @Path('id') required String id,
  });

  @Post(path: '/decks/{id}/cards')
  Future<Response> addCard({
    @Path('id') required String id,
    @Body() required CardDto body,
  });

  @Post(path: '/decks/{id}/cards/batch')
  Future<Response> addCards({
    @Path('id') required String id,
    @Body() required List<CardDto> body,
  });
}
