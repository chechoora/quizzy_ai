import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// The `quizzy` flavor has no backend account to attribute events to, so
/// every method is a stub. Kept as a real class (rather than skipping
/// registration) so callers can always depend on [AnalyticsService] without
/// checking the flavor first.
class NoopAnalyticsService implements AnalyticsService {
  NoopAnalyticsService({required this.logger});

  final Logger logger;

  @override
  void start() {
    logger.d('start: analytics disabled for this flavor, no-op');
  }

  @override
  Future<void> track(String name, {Map<String, dynamic>? properties}) async {
    logger.d('track: analytics disabled for this flavor, dropping $name');
  }

  @override
  void dispose() {
    logger.d('dispose: no-op');
  }
}
