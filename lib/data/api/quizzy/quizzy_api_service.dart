import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';

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
    @Query('userId') required String userId,
    @Body() required CheckAnswerRequest body,
  });

  @Post(path: '/decks/generate')
  Future<Response> generateDeck({
    @Query('userId') required String userId,
    @Body() required GenerateDeckRequest body,
  });

  @Get(path: '/users/{appUserId}/balance')
  Future<Response> getQuota({
    @Path('appUserId') required String appUserId,
  });
}

class GenerateDeckRequest {
  final String prompt;
  final String? deckTitle;
  final List<PlainCardModel> currentCards;

  GenerateDeckRequest({
    required this.prompt,
    this.deckTitle,
    this.currentCards = const [],
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        if (deckTitle != null) 'deckTitle': deckTitle,
        if (currentCards.isNotEmpty)
          'currentCards': currentCards
              .map((c) => {'question': c.question, 'answer': c.answer})
              .toList(),
      };
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
