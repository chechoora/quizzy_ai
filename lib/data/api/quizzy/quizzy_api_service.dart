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

  @Get(path: '/users/{appUserId}/balance')
  Future<Response<QuotaResponse>> getQuota({
    @Path('appUserId') required String appUserId,
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
  final double weeklyBalanceUsd;
  final double weeklyLimitUsd;
  final int weeklyBalanceReq;
  final int weeklyLimitReq;

  QuotaResponse({
    required this.weeklyBalanceUsd,
    required this.weeklyLimitUsd,
    required this.weeklyBalanceReq,
    required this.weeklyLimitReq,
  });

  factory QuotaResponse.fromJson(Map<String, dynamic> json) => QuotaResponse(
        weeklyBalanceUsd: (json['weeklyBalanceUsd'] as num).toDouble(),
        weeklyLimitUsd: (json['weeklyLimitUsd'] as num).toDouble(),
        weeklyBalanceReq: json['weeklyBalanceReq'] as int,
        weeklyLimitReq: json['weeklyLimitReq'] as int,
      );

  Map<String, dynamic> toJson() => {
        'weeklyBalanceUsd': weeklyBalanceUsd,
        'weeklyLimitUsd': weeklyLimitUsd,
        'weeklyBalanceReq': weeklyBalanceReq,
        'weeklyLimitReq': weeklyLimitReq,
      };
}
