import 'package:poc_ai_quiz/data/user_quota/user_quota_pref_data_source.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/user_balance_repository.dart';
import 'package:poc_ai_quiz/domain/user/model/quota_item.dart';

class UserQuotaRepository {
  final UserBalanceRepository userBalanceRepository;
  final UserQuotaPrefDataSource prefDataSource;

  UserQuotaRepository({
    required this.userBalanceRepository,
    required this.prefDataSource,
  });

  Stream<QuotaItem> fetchQuota() async* {
    // Emit cached data first if available
    if (prefDataSource.hasValidCache()) {
      final weeklyPercentUsage = prefDataSource.getWeeklyPercentUsage();
      final questionsLeft = prefDataSource.getQuestionsLeft();

      if (weeklyPercentUsage != null && questionsLeft != null) {
        yield QuotaItem(
          weeklyPercentUsage: weeklyPercentUsage,
          questionsLeft: questionsLeft,
        );
      }
    }

    // Fetch fresh data from API
    final balance = await userBalanceRepository.getBalance();
    final weeklyPercentUsage =
        ((balance.weeklyLimitUsd - balance.weeklyBalanceUsd) /
                balance.weeklyLimitUsd) *
            100;
    final questionsLeft = balance.weeklyBalanceReq.toInt();
    // Cache the result
    await prefDataSource.saveQuota(
      weeklyPercentUsage: weeklyPercentUsage.toDouble(),
      questionsLeft: questionsLeft,
    );

    yield QuotaItem(
      weeklyPercentUsage: weeklyPercentUsage.toDouble(),
      questionsLeft: questionsLeft,
    );
  }

  Future<void> clearCache() async {
    await prefDataSource.clearQuota();
  }
}
