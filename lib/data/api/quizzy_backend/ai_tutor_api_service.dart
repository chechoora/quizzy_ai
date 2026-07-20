import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';

part 'ai_tutor_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class AiTutorApiService extends ChopperService {
  static AiTutorApiService create([ChopperClient? client]) {
    final service = _$AiTutorApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Post(path: '/ai-tutor/check-answer')
  Future<Response> checkAnswer({
    @Body() required CheckAnswerDto body,
  });
}
