import 'package:chopper/chopper.dart';

part 'gemini_api_service.chopper.dart';

@ChopperApi()
abstract class GeminiApiService extends ChopperService {
  static GeminiApiService create([ChopperClient? client]) => _$GeminiApiService(client);

  @Post(path: ':model:generateContent')
  Future<Response> generateContent({
    @Path('model') required String model,
    @Body() required Map<String, dynamic> body,
  });
}