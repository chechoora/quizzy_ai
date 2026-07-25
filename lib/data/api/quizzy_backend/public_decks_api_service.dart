import 'package:chopper/chopper.dart';

part 'public_decks_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class PublicDecksApiService extends ChopperService {
  static PublicDecksApiService create([ChopperClient? client]) {
    final service = _$PublicDecksApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Get(path: '/public/categories')
  Future<Response> listCategories();

  @Get(path: '/public/decks')
  Future<Response> listDecks({
    @Query('category') String? category,
    @Query('tag') String? tag,
    @Query('q') String? q,
  });

  @Get(path: '/public/decks/{id}')
  Future<Response> getDeck({
    @Path('id') required String id,
  });

  @Post(path: '/public/decks/{id}/copy', optionalBody: true)
  Future<Response> copyDeck({
    @Path('id') required String id,
  });
}
