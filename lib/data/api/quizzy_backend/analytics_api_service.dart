import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';

part 'analytics_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class AnalyticsApiService extends ChopperService {
  static AnalyticsApiService create([ChopperClient? client]) {
    final service = _$AnalyticsApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Post(path: '/analytics/events')
  Future<Response> trackEvents({
    @Body() required TrackEventsDto body,
  });
}
