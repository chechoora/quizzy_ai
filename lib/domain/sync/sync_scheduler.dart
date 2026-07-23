import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Schedules two-way sync with the quizzy-ai-pro backend. Mirrors
/// [BackupScheduler]'s reactive-debounce pattern (deck/card DB watch streams
/// trigger a debounced sync), plus a periodic timer, a pull on sign-in, and a
/// pull on app foreground/launch. No-ops entirely when [enabled] is false
/// (the `quizzy` flavor) or while signed out.
class SyncScheduler with WidgetsBindingObserver {
  SyncScheduler({
    required this.deckRepository,
    required this.quizCardRepository,
    required this.syncService,
    required this.authService,
    required this.logger,
    required this.enabled,
    this.debounce = const Duration(seconds: 5),
    this.pullInterval = const Duration(minutes: 15),
  });

  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final DeckCardSyncService syncService;
  final AuthService authService;
  final Logger logger;
  final bool enabled;
  final Duration debounce;
  final Duration pullInterval;

  /// Whether a sync is currently running, for a UI progress indicator.
  /// Forwarded from [syncService], since ad hoc callers like
  /// [QuizExeCubit]/[PublicDeckDetailCubit] can also drive it in flight
  /// outside of this scheduler.
  ValueListenable<bool> get isSyncing => syncService.isSyncing;

  Timer? _debounceTimer;
  Timer? _periodicTimer;
  bool _started = false;
  bool _signedIn = false;
  StreamSubscription<dynamic>? _deckSub;
  StreamSubscription<dynamic>? _cardSub;
  StreamSubscription<dynamic>? _authSub;

  /// Subscribes to deck/card changes, auth state, and app lifecycle so sync
  /// runs reactively, periodically, on sign-in, and on foreground/launch.
  void start() {
    if (!enabled) {
      logger.d('start: sync disabled for this flavor');
      return;
    }
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
        logger.i('auth: signed in, triggering sync');
        _scheduleDebounced();
      } else if (wasSignedIn && !_signedIn) {
        logger.d('auth: signed out, sync paused');
      }
    });

    _deckSub ??= deckRepository.watchDecks().skip(1).listen((_) {
      logger.d('deck change detected, scheduling sync');
      _scheduleDebounced();
    });
    _cardSub ??= quizCardRepository.watchCards().skip(1).listen((_) {
      logger.d('card change detected, scheduling sync');
      _scheduleDebounced();
    });

    _periodicTimer = Timer.periodic(pullInterval, (_) => unawaited(_runSync()));

    WidgetsBinding.instance.addObserver(this);

    logger.i('start: sync watching deck & card changes, '
        'periodic every ${pullInterval.inMinutes}min');

    if (_signedIn) {
      unawaited(_runSync());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.d('didChangeAppLifecycleState: resumed, triggering sync');
      unawaited(_runSync());
    }
  }

  void _scheduleDebounced() {
    _debounceTimer?.cancel();
    logger.d('_scheduleDebounced: sync debounced for ${debounce.inSeconds}s');
    _debounceTimer = Timer(debounce, () => unawaited(_runSync()));
  }

  Future<void> _runSync() async {
    if (isSyncing.value) {
      logger.d('_runSync: already in flight, rescheduling');
      _scheduleDebounced();
      return;
    }
    if (!_signedIn) {
      logger.w('_runSync: not signed in, skipping');
      return;
    }
    logger.d('_runSync: starting');
    try {
      final result = await syncService.runFullSync();
      logger.i('_runSync: complete, $result');
    } catch (e, s) {
      logger.e('_runSync: sync failed', ex: e, stacktrace: s);
    }
  }

  void dispose() {
    logger.d('dispose: cancelling timers & subscriptions');
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _deckSub?.cancel();
    _cardSub?.cancel();
    _authSub?.cancel();
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
