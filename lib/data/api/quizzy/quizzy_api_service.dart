import 'package:chopper/chopper.dart';

part 'quizzy_api_service.chopper.dart';

@ChopperApi(baseUrl: '/v1/api')
abstract class QuizzyApiService extends ChopperService {
  static QuizzyApiService create([ChopperClient? client]) {
    final service = _$QuizzyApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Post()
  Future<Response> validateAnswer({
    @Body() required Map<String, dynamic> body,
  });
}
