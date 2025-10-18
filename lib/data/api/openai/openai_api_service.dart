import 'package:chopper/chopper.dart';

part 'openai_api_service.chopper.dart';

@ChopperApi(baseUrl: '/chat/completions')
abstract class OpenAIApiService extends ChopperService {
  static OpenAIApiService create([ChopperClient? client]) {
    return _$OpenAIApiService(client);
  }

  @Post()
  Future<Response> createChatCompletion({
    @Body() required Map<String, dynamic> body,
  });
}