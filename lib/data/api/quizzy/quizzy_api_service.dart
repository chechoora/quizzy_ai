import 'package:chopper/chopper.dart';

part 'quizzy_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api/ai-tutor/check-answer')
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
    @Body() required CheckAnswerRequest body,
  });
}

class CheckAnswerRequest {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String? context;

  CheckAnswerRequest({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        if (context != null) 'context': context,
      };
}
