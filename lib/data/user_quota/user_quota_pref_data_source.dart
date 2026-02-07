import 'package:shared_preferences/shared_preferences.dart';

class UserQuotaPrefDataSource {
  static const String _keyWeeklyPercentUsage = 'user_quota_weekly_percent_usage';
  static const String _keyQuestionsLeft = 'user_quota_questions_left';
  static const String _keyLastUpdated = 'user_quota_last_updated';

  final SharedPreferences prefs;

  UserQuotaPrefDataSource({
    required this.prefs,
  });

  Future<void> saveQuota({
    required double weeklyPercentUsage,
    required int questionsLeft,
  }) async {
    await prefs.setDouble(_keyWeeklyPercentUsage, weeklyPercentUsage);
    await prefs.setInt(_keyQuestionsLeft, questionsLeft);
    await prefs.setInt(_keyLastUpdated, DateTime.now().millisecondsSinceEpoch);
  }

  double? getWeeklyPercentUsage() {
    return prefs.getDouble(_keyWeeklyPercentUsage);
  }

  int? getQuestionsLeft() {
    return prefs.getInt(_keyQuestionsLeft);
  }

  DateTime? getLastUpdated() {
    final timestamp = prefs.getInt(_keyLastUpdated);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  bool hasValidCache({Duration maxAge = const Duration(minutes: 5)}) {
    final lastUpdated = getLastUpdated();
    if (lastUpdated == null) return false;

    final age = DateTime.now().difference(lastUpdated);
    return age <= maxAge;
  }

  Future<void> clearQuota() async {
    await prefs.remove(_keyWeeklyPercentUsage);
    await prefs.remove(_keyQuestionsLeft);
    await prefs.remove(_keyLastUpdated);
  }
}