import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:poc_ai_quiz/data/api/quizzy_backend/quizzy_backend_models.dart';
import 'package:poc_ai_quiz/data/db/analytics/analytics_event_database_repository.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/analytics_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// The `quizzypro` [AnalyticsService]: queues events locally (so [track]
/// never blocks the caller and survives offline periods) and flushes them to
/// `POST /api/analytics/events` in batches, debounced after each [track]
/// call, periodically, on sign-in, and on app foreground — mirroring
/// `SyncScheduler`'s trigger set, simplified since analytics has no
/// push/pull business logic to separate out from scheduling.
///
/// On a successful batch, queued rows are deleted regardless of the
/// server-reported `accepted` count (dedup is server-side, keyed by the
/// client-generated event id). On a `400`, the batch is dropped rather than
/// retried — retrying a batch the server has already rejected would poison
/// the queue and block every event queued behind it. On a `5xx` or
/// network/other error, the batch is left queued for the next trigger.
class RemoteAnalyticsService with WidgetsBindingObserver implements AnalyticsService {
  RemoteAnalyticsService({
    required this.eventDataBaseRepository,
    required this.analyticsRepository,
    required this.authService,
    required this.appVersion,
    required this.logger,
    this.debounce = const Duration(seconds: 3),
    this.flushInterval = const Duration(minutes: 2),
    this.maxBatchSize = 50,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  final AnalyticsEventDataBaseRepository eventDataBaseRepository;
  final AnalyticsRepository analyticsRepository;
  final AuthService authService;
  final String appVersion;
  final Logger logger;
  final Duration debounce;
  final Duration flushInterval;
  final int maxBatchSize;
  final Uuid uuid;

  Timer? _debounceTimer;
  Timer? _periodicTimer;
  StreamSubscription<dynamic>? _authSub;
  bool _started = false;
  bool _flushing = false;
  bool _signedIn = false;

  @override
  void start() {
    if (_started) {
      logger.d('start: already started');
      return;
    }
    _started = true;

    _signedIn = authService.currentUser != null;
    _authSub = authService.authStateChanges.listen((user) {
      final wasSignedIn = _signedIn;
      _signedIn = user != null;
      if (!wasSignedIn && _signedIn) {
        logger.i('auth: signed in, triggering flush');
        _scheduleDebounced();
      }
    });

    _periodicTimer = Timer.periodic(flushInterval, (_) => unawaited(_flush()));
    WidgetsBinding.instance.addObserver(this);

    logger.i('start: analytics watching for events, periodic flush every '
        '${flushInterval.inMinutes}min');

    if (_signedIn) {
      unawaited(_flush());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.d('didChangeAppLifecycleState: resumed, triggering flush');
      _scheduleDebounced();
    }
  }

  @override
  Future<void> track(String name, {Map<String, dynamic>? properties}) async {
    logger.d('track: name=$name');
    try {
      final mergedProperties = {
        ...?properties,
        'app_version': appVersion,
      };
      await eventDataBaseRepository.enqueue(
        id: uuid.v4(),
        name: name,
        timestamp: DateTime.now().toUtc(),
        propertiesJson: jsonEncode(mergedProperties),
      );
      _scheduleDebounced();
    } catch (e, stackTrace) {
      logger.e('track: failed to enqueue $name', ex: e, stacktrace: stackTrace);
    }
  }

  void _scheduleDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(_flush()));
  }

  Future<void> _flush() async {
    if (_flushing) {
      logger.d('_flush: already flushing, skipping');
      return;
    }
    if (!_signedIn) {
      logger.d('_flush: not signed in, skipping');
      return;
    }
    _flushing = true;
    try {
      while (true) {
        final batch = await eventDataBaseRepository.peekBatch(maxBatchSize);
        if (batch.isEmpty) break;

        final dtos = batch
            .map((row) => AnalyticsEventDto(
                  id: row.id,
                  name: row.name,
                  timestamp: row.timestamp.toIso8601String(),
                  properties: row.propertiesJson == null
                      ? null
                      : jsonDecode(row.propertiesJson!) as Map<String, dynamic>,
                ))
            .toList();
        final ids = batch.map((row) => row.id).toList();

        try {
          final accepted = await analyticsRepository.trackEvents(dtos);
          logger.d('_flush: sent ${dtos.length}, accepted=$accepted');
          await eventDataBaseRepository.deleteByIds(ids);
        } catch (e, stackTrace) {
          if (e is QuizzyBackendException && e.statusCode == 400) {
            logger.e(
              '_flush: batch rejected (400), dropping ${ids.length} events '
              'to avoid poisoning the queue',
              ex: e,
              stacktrace: stackTrace,
            );
            await eventDataBaseRepository.deleteByIds(ids);
          } else {
            logger.w(
              '_flush: batch failed, will retry on next trigger',
              ex: e,
              stacktrace: stackTrace,
            );
          }
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  @override
  void dispose() {
    logger.d('dispose: cancelling timers & subscriptions');
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _authSub?.cancel();
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
