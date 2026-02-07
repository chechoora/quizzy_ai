import 'package:poc_ai_quiz/data/api/quizzy/quizzy_api_service.dart';
import 'package:poc_ai_quiz/data/user_quota/user_quota_pref_data_source.dart';
import 'package:poc_ai_quiz/domain/user/model/quota_item.dart';

class UserQuotaRepository {
  final QuizzyApiService apiService;
  final UserQuotaPrefDataSource prefDataSource;

  UserQuotaRepository({
    required this.apiService,
    required this.prefDataSource,
  });

  Stream<QuotaItem> fetchQuota(String appUserId) async* {
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
    final response = await apiService.getQuota(
      appUserId: appUserId,
    );

    if (response.isSuccessful && response.body != null) {
      final quotaResponse = response.body!;

      // Cache the result
      await prefDataSource.saveQuota(
        weeklyPercentUsage: quotaResponse.weeklyPercentUsage,
        questionsLeft: quotaResponse.questionsLeft,
      );

      yield QuotaItem(
        weeklyPercentUsage: quotaResponse.weeklyPercentUsage,
        questionsLeft: quotaResponse.questionsLeft,
      );
    } else {
      throw Exception('Failed to fetch quota: ${response.error}');
    }
  }

  Future<void> clearCache() async {
    await prefDataSource.clearQuota();
  }
}
