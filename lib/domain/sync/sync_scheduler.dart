import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// The sole entry point for two-way sync with the quizzy-ai-pro backend — no
/// other class should hold a [DeckCardSyncService] reference. Triggers a
/// [DeckCardSyncService.runFullSync] cycle reactively (dirty deck/card/
/// tombstone counts moving), periodically, on sign-in, and on app
/// foreground/launch; also exposes [syncNow] for callers that need a fresh
/// sync before proceeding (e.g. after finishing a quiz, or after copying a
/// public deck). No-ops entirely when [enabled] is false (the `quizzy`
/// flavor) or while signed out.
///
/// [syncNow] is single-flight: concurrent callers share the one in-flight
/// cycle's [Future]. A trigger arriving mid-cycle is coalesced into exactly
/// one extra cycle immediately after, rather than queuing indefinitely.
/// Reactive dirty-count triggers are suppressed entirely while a cycle is in
/// flight; once it finishes, real leftover work (if any) triggers exactly
/// one follow-up cycle rather than one per trigger signal received.
class SyncScheduler with WidgetsBindingObserver {
  SyncScheduler({
    required this.deckRepository,
    required this.quizCardRepository,
    required this.tombstoneRepository,
    required this.syncService,
    required this.authService,
    required this.logger,
    required this.enabled,
    this.debounce = const Duration(seconds: 5),
    this.pullInterval = const Duration(minutes: 15),
  });

  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final SyncTombstoneRepository tombstoneRepository;
  final DeckCardSyncService syncService;
  final AuthService authService;
  final Logger logger;
  final bool enabled;
  final Duration debounce;
  final Duration pullInterval;

  static const _backoffSteps = [
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 120),
    Duration(seconds: 300),
  ];

  final ValueNotifier<bool> _isSyncing = ValueNotifier<bool>(false);

  /// Whether a sync cycle is currently running, for a UI progress indicator.
  ValueListenable<bool> get isSyncing => _isSyncing;

  Future<void>? _inFlight;
  bool _pendingRerun = false;

  int _backoffIndex = -1;
  bool _inBackoff = false;
  Timer? _backoffTimer;

  Timer? _debounceTimer;
  Timer? _periodicTimer;
  bool _started = false;
  bool _signedIn = false;
  StreamSubscription<dynamic>? _dirtyDeckSub;
  StreamSubscription<dynamic>? _dirtyCardSub;
  StreamSubscription<dynamic>? _tombstoneSub;
  StreamSubscription<dynamic>? _authSub;

  /// Subscribes to dirty deck/card/tombstone counts, auth state, and app
  /// lifecycle so sync runs reactively, periodically, on sign-in, and on
  /// foreground/launch.
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

    // Dirty-count-only triggers (rather than watching the full deck/card
    // tables) so the sync's own writes (markSynced, upsertFromRemote — both
    // write isDirty: false) never re-trigger a sync themselves.
    _dirtyDeckSub ??= deckRepository.watchDirtyDeckCount().skip(1).listen((_) {
      _onDirtyTrigger('dirty deck count');
    });
    _dirtyCardSub ??=
        quizCardRepository.watchDirtyCardCount().skip(1).listen((_) {
      _onDirtyTrigger('dirty card count');
    });
    _tombstoneSub ??=
        tombstoneRepository.watchTombstoneCount().skip(1).listen((_) {
      _onDirtyTrigger('tombstone count');
    });

    _periodicTimer = Timer.periodic(pullInterval, (_) => _triggerAutomatic());

    WidgetsBinding.instance.addObserver(this);

    logger.i('start: sync watching dirty deck/card/tombstone counts, '
        'periodic every ${pullInterval.inMinutes}min');

    if (_signedIn) {
      unawaited(syncNow());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.d('didChangeAppLifecycleState: resumed, triggering sync');
      _triggerAutomatic();
    }
  }

  /// Handles a dirty-deck/dirty-card/tombstone count emission. Suppressed
  /// entirely while a cycle is in flight — that cycle's own upserts
  /// (isDirty: false) don't move these counts, but *other* concurrent
  /// writers (e.g. the user editing a card mid-cycle) legitimately can, and
  /// reacting to every one of those mid-cycle would just re-debounce
  /// pointlessly. Instead, [_runCycle] checks for real leftover work once
  /// the cycle finishes and schedules exactly one follow-up if needed.
  void _onDirtyTrigger(String source) {
    if (_inFlight != null) {
      logger.d('$source changed while a cycle is in flight, suppressing '
          'trigger');
      return;
    }
    logger.d('$source changed, scheduling sync');
    _scheduleDebounced();
  }

  void _scheduleDebounced() {
    _debounceTimer?.cancel();
    logger.d('_scheduleDebounced: sync debounced for ${debounce.inSeconds}s');
    _debounceTimer = Timer(debounce, _triggerAutomatic);
  }

  /// Routes automatic triggers (debounce, periodic, foreground) through the
  /// 429 backoff gate. [syncNow] itself is never gated — user-initiated
  /// calls always run.
  void _triggerAutomatic() {
    if (_inBackoff) {
      logger.d('_triggerAutomatic: suppressed during backoff');
      return;
    }
    unawaited(syncNow());
  }

  /// Runs a full sync cycle, or joins the currently in-flight one. If a
  /// trigger arrives while a cycle is already running, exactly one more
  /// cycle runs immediately after the current one finishes (coalescing) —
  /// the returned [Future] still only resolves when the *current* cycle
  /// completes.
  Future<void> syncNow() {
    if (!enabled) {
      logger.d('syncNow: sync disabled for this flavor');
      return Future.value();
    }
    final inFlight = _inFlight;
    if (inFlight != null) {
      logger.d('syncNow: cycle already in flight, coalescing');
      _pendingRerun = true;
      return inFlight;
    }
    if (!_signedIn) {
      logger.d('syncNow: not signed in, skipping');
      return Future.value();
    }
    // The in-flight future is recorded via a Completer *before* [_runCycle]
    // is invoked, rather than assigning `_inFlight = _runCycle()` after the
    // call. `syncService.runFullSync()` throwing synchronously (no real
    // async gap) lets an async function run its entire body — including its
    // `finally` — to completion before ever yielding back to this caller;
    // assigning `_inFlight` afterwards would then clobber the `null` that
    // finally had already set, leaking a stale non-null `_inFlight` forever.
    final completer = Completer<void>();
    _inFlight = completer.future;
    unawaited(_runCycle(completer));
    return completer.future;
  }

  Future<void> _runCycle(Completer<void> completer) async {
    _isSyncing.value = true;
    try {
      do {
        _pendingRerun = false;
        try {
          final result = await syncService.runFullSync();
          logger.i('_runCycle: complete, $result');
          _resetBackoff();
        } catch (e, s) {
          if (e is QuizzyBackendException && e.statusCode == 429) {
            _enterBackoff(e.retryAfter);
            // Don't let a coalesced rerun immediately retry into the backoff
            // window it was just told to respect.
            break;
          } else {
            logger.e('_runCycle: sync failed', ex: e, stacktrace: s);
          }
        }
      } while (_pendingRerun && _signedIn);
    } finally {
      _inFlight = null;
      _isSyncing.value = false;
      completer.complete();
    }

    // Reactive dirty-count triggers were suppressed for the whole cycle
    // above (see _onDirtyTrigger) — check for real leftover work now that
    // the in-flight slot is free, and schedule exactly one follow-up if any
    // remains, instead of relying on however many trigger signals arrived.
    if (_signedIn && !_inBackoff && await _hasPendingWork()) {
      logger.d('_runCycle: pending work remains, scheduling follow-up');
      _scheduleDebounced();
    }
  }

  /// Whether there's real unpushed work (dirty decks/cards, or pending
  /// tombstones) still sitting locally, checked right after a cycle so a
  /// follow-up is only scheduled when there's something to actually do.
  Future<bool> _hasPendingWork() async {
    if ((await deckRepository.fetchDirtyDecks()).isNotEmpty) return true;
    if ((await quizCardRepository.fetchDirtyCards()).isNotEmpty) return true;
    if ((await tombstoneRepository.fetchTombstones('deck')).isNotEmpty) {
      return true;
    }
    return (await tombstoneRepository.fetchTombstones('card')).isNotEmpty;
  }

  void _enterBackoff(Duration? retryAfter) {
    _backoffIndex = (_backoffIndex + 1).clamp(0, _backoffSteps.length - 1);
    final delay = retryAfter ?? _backoffSteps[_backoffIndex];
    _inBackoff = true;
    logger.w('_enterBackoff: 429 received, pausing automatic triggers for '
        '${delay.inSeconds}s');
    _backoffTimer?.cancel();
    _backoffTimer = Timer(delay, () {
      _inBackoff = false;
      logger.d('_enterBackoff: backoff window elapsed, automatic triggers '
          'resumed');
    });
  }

  void _resetBackoff() {
    if (_backoffIndex != -1) {
      logger.d('_resetBackoff: sync succeeded, resetting backoff');
    }
    _backoffIndex = -1;
    _inBackoff = false;
    _backoffTimer?.cancel();
  }

  void dispose() {
    logger.d('dispose: cancelling timers & subscriptions');
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _backoffTimer?.cancel();
    _dirtyDeckSub?.cancel();
    _dirtyCardSub?.cancel();
    _tombstoneSub?.cancel();
    _authSub?.cancel();
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
