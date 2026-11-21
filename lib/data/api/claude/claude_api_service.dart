import 'package:chopper/chopper.dart';

part 'claude_api_service.chopper.dart';

@ChopperApi(baseUrl: '/messages')
abstract class ClaudeApiService extends ChopperService {
  static ClaudeApiService create([ChopperClient? client]) {
    return _$ClaudeApiService(client);
  }

  @Post()
  Future<Response> createMessage({
    @Body() required Map<String, dynamic> body,
  });
}

@ChopperApi(baseUrl: '/models')
abstract class ClaudeModelsApiService extends ChopperService {
  static ClaudeModelsApiService create([ChopperClient? client]) {
    return _$ClaudeModelsApiService(client);
  }

  @Get()
  Future<Response> listModels({
    @Header('x-api-key') required String apiKey,
    @Query('limit') int limit = 1000,
  });
}
