import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/analytics_api_service.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Thin wrapper over `POST /api/analytics/events` on the quizzy-ai-pro-be
/// backend. Throws [QuizzyBackendException] (with `statusCode` set) on any
/// non-2xx response so [RemoteAnalyticsService] can decide whether the batch
/// is retriable (5xx/network) or must be dropped (400).
class AnalyticsRepository {
  AnalyticsRepository({
    required this.apiService,
    required this.logger,
  });

  final AnalyticsApiService apiService;
  final Logger logger;

  /// Sends [events] as a single batch. Returns the server-reported accepted
  /// count (may be less than `events.length` when some are duplicates
  /// already seen server-side) — callers should log it as a debug signal
  /// only, never act on it, since dedup/whitelisting happen server-side.
  Future<int> trackEvents(List<AnalyticsEventDto> events) async {
    logger.d('trackEvents: count=${events.length}');
    try {
      final response = await apiService.trackEvents(
        body: TrackEventsDto(events: events),
      );
      final body = _requireBody(response, 'trackEvents');
      final accepted =
          TrackEventsResponseDto.fromJson(body as Map<String, dynamic>)
              .accepted;
      logger.d('trackEvents: accepted=$accepted of ${events.length}');
      return accepted;
    } catch (e, stackTrace) {
      logger.e('trackEvents: failed', ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }

  dynamic _requireBody(Response response, String operation) {
    if (!response.isSuccessful || response.body == null) {
      throw QuizzyBackendException(
        'Failed to $operation: ${response.statusCode}, ${response.error}',
        statusCode: response.statusCode,
        retryAfter: _retryAfterFrom(response),
      );
    }
    return response.body;
  }

  Duration? _retryAfterFrom(Response response) {
    String? raw;
    for (final entry in response.base.headers.entries) {
      if (entry.key.toLowerCase() == 'retry-after') {
        raw = entry.value;
        break;
      }
    }
    final seconds = raw == null ? null : int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
