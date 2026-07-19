import 'package:chopper/chopper.dart';

part 'user_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class UserApiService extends ChopperService {
  static UserApiService create([ChopperClient? client]) {
    final service = _$UserApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Get(path: '/users/me/balance')
  Future<Response> getBalance();
}
