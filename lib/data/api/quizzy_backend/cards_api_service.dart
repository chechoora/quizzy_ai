import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';

part 'cards_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class CardsApiService extends ChopperService {
  static CardsApiService create([ChopperClient? client]) {
    final service = _$CardsApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Patch(path: '/cards/{id}')
  Future<Response> updateCard({
    @Path('id') required String id,
    @Body() required UpdateCardDto body,
  });

  @Delete(path: '/cards/{id}')
  Future<Response> deleteCard({
    @Path('id') required String id,
  });
}
