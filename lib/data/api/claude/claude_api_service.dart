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