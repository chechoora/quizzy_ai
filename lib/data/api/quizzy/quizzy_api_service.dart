import 'package:chopper/chopper.dart';

part 'quizzy_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class QuizzyApiService extends ChopperService {
  static QuizzyApiService create([ChopperClient? client]) {
    final service = _$QuizzyApiService();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  @Post(path: '/ai-tutor/check-answer')
  Future<Response> validateAnswer({
    @Body() required CheckAnswerRequest body,
  });

  @Get(path: '/ai-tutor/quota')
  Future<Response<QuotaResponse>> getQuota({
    @Query('appUserId') required String appUserId,
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

class QuotaResponse {
  final double weeklyPercentUsage;
  final int questionsLeft;

  QuotaResponse({
    required this.weeklyPercentUsage,
    required this.questionsLeft,
  });

  factory QuotaResponse.fromJson(Map<String, dynamic> json) => QuotaResponse(
        weeklyPercentUsage: (json['weekly_percent_usage'] as num).toDouble(),
        questionsLeft: json['questions_left'] as int,
      );

  Map<String, dynamic> toJson() => {
        'weekly_percent_usage': weeklyPercentUsage,
        'questions_left': questionsLeft,
      };
}
