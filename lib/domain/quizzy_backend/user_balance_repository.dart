import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/user_api_service.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/user_balance.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Weekly usage/balance for the authenticated user, against the
/// quizzy-ai-pro-be backend.
class UserBalanceRepository {
  UserBalanceRepository({
    required this.apiService,
    required this.logger,
  });

  final UserApiService apiService;
  final Logger logger;

  Future<UserBalance> getBalance() async {
    logger.d('getBalance: starting');
    try {
      final response = await apiService.getBalance();
      if (!response.isSuccessful || response.body == null) {
        logger.e('getBalance: failed with status ${response.statusCode}');
        throw QuizzyBackendException(
            'Failed to get balance: ${response.statusCode}, ${response.error}');
      }
      final dto =
          UserBalanceDto.fromJson(response.body as Map<String, dynamic>);
      logger.i('getBalance: success');
      return UserBalance(
        weeklyBalanceUsd: dto.weeklyBalanceUsd,
        weeklyLimitUsd: dto.weeklyLimitUsd,
        weeklyBalanceReq: dto.weeklyBalanceReq,
        weeklyLimitReq: dto.weeklyLimitReq,
      );
    } catch (e, stackTrace) {
      logger.e('getBalance: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
