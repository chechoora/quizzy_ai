import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/domain/sync/model/sync_result.dart';
import 'package:poc_ai_quiz/domain/sync/sync_scheduler.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockSyncTombstoneRepository extends Mock
    implements SyncTombstoneRepository {}

class MockDeckCardSyncService extends Mock implements DeckCardSyncService {}

class MockAuthService extends Mock implements AuthService {}

class FakeAuthUser extends Fake implements AuthUser {}

const _debounce = Duration(milliseconds: 20);
const _pullInterval = Duration(hours: 1);
const _okResult =
    SyncRunResult(push: SyncPushResult(), pull: SyncPullResult());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockSyncTombstoneRepository tombstoneRepository;
  late MockDeckCardSyncService syncService;
  late MockAuthService authService;
  late StreamController<int> dirtyDeckController;
  late StreamController<int> dirtyCardController;
  late StreamController<int> tombstoneController;
  late StreamController<AuthUser?> authController;

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    tombstoneRepository = MockSyncTombstoneRepository();
    syncService = MockDeckCardSyncService();
    authService = MockAuthService();
    dirtyDeckController = StreamController<int>.broadcast();
    dirtyCardController = StreamController<int>.broadcast();
    tombstoneController = StreamController<int>.broadcast();
    authController = StreamController<AuthUser?>.broadcast();

    when(() => deckRepository.watchDirtyDeckCount())
        .thenAnswer((_) => dirtyDeckController.stream);
    when(() => quizCardRepository.watchDirtyCardCount())
        .thenAnswer((_) => dirtyCardController.stream);
    when(() => tombstoneRepository.watchTombstoneCount())
        .thenAnswer((_) => tombstoneController.stream);
    when(() => authService.authStateChanges)
        .thenAnswer((_) => authController.stream);
    when(() => syncService.runFullSync()).thenAnswer((_) async => _okResult);

    // Post-cycle pending-work check defaults to "nothing left to do" so
    // existing tests don't need to know about it; tests that care about the
    // follow-up behavior override these.
    when(() => deckRepository.fetchDirtyDecks()).thenAnswer((_) async => []);
    when(() => quizCardRepository.fetchDirtyCards())
        .thenAnswer((_) async => []);
    when(() => tombstoneRepository.fetchTombstones(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() async {
    await dirtyDeckController.close();
    await dirtyCardController.close();
    await tombstoneController.close();
    await authController.close();
  });

  SyncScheduler buildScheduler({required bool enabled}) {
    return SyncScheduler(
      deckRepository: deckRepository,
      quizCardRepository: quizCardRepository,
      tombstoneRepository: tombstoneRepository,
      syncService: syncService,
      authService: authService,
      logger: Logger.withTag('test'),
      enabled: enabled,
      debounce: _debounce,
      pullInterval: _pullInterval,
    );
  }

  test('start() no-ops when disabled, isSyncing stays false', () async {
    when(() => authService.currentUser).thenReturn(null);
    final scheduler = buildScheduler(enabled: false);
    addTearDown(scheduler.dispose);

    scheduler.start();
    await scheduler.syncNow();
    await Future.delayed(_debounce * 2);

    verifyNever(() => syncService.runFullSync());
    expect(scheduler.isSyncing.value, isFalse);
  });

  test('a burst of dirty-count changes coalesces into one sync call',
      () async {
    when(() => authService.currentUser).thenReturn(FakeAuthUser());
    final scheduler = buildScheduler(enabled: true);
    addTearDown(scheduler.dispose);

    scheduler.start();
    // Let the "already signed in at start" initial sync fire and settle,
    // then stop counting it.
    await Future.delayed(_debounce * 2);
    clearInteractions(syncService);

    // First post-subscription event is swallowed by .skip(1).
    dirtyDeckController.add(0);
    await Future.delayed(Duration.zero);

    // A burst of dirty-count changes should coalesce into a single
    // debounced sync.
    dirtyCardController.add(1);
    dirtyCardController.add(2);
    tombstoneController.add(1);
    await Future.delayed(_debounce * 2);

    verify(() => syncService.runFullSync()).called(1);
  });

  test('a pull-only write (dirty count unchanged) does not trigger a sync',
      () async {
    // markSynced/upsertFromRemote write isDirty: false, so a pull cycle
    // never moves the dirty-count streams — nothing to simulate here beyond
    // confirming the scheduler only reacts to stream *emissions*, which is
    // exactly what the repository-level count query (not the full-table
    // watch) guarantees. This test documents that contract at the scheduler
    // boundary: no emission, no sync.
    when(() => authService.currentUser).thenReturn(FakeAuthUser());
    final scheduler = buildScheduler(enabled: true);
    addTearDown(scheduler.dispose);

    scheduler.start();
    await Future.delayed(_debounce * 2);
    clearInteractions(syncService);

    await Future.delayed(_debounce * 2);

    verifyNever(() => syncService.runFullSync());
  });

  test('sync is skipped while signed out and fires once on sign-in',
      () async {
    when(() => authService.currentUser).thenReturn(null);
    final scheduler = buildScheduler(enabled: true);
    addTearDown(scheduler.dispose);

    scheduler.start();
    await Future.delayed(Duration.zero);

    // Swallowed by skip(1).
    dirtyDeckController.add(0);
    await Future.delayed(Duration.zero);

    // A dirty-count change while signed out must not trigger a sync.
    dirtyDeckController.add(1);
    await Future.delayed(_debounce * 2);
    verifyNever(() => syncService.runFullSync());

    // Signing in triggers exactly one sync.
    authController.add(FakeAuthUser());
    await Future.delayed(_debounce * 2);

    verify(() => syncService.runFullSync()).called(1);
  });

  group('syncNow single-flight/coalescing', () {
    test('concurrent syncNow() calls share the one in-flight cycle',
        () async {
      when(() => authService.currentUser).thenReturn(FakeAuthUser());
      final scheduler = buildScheduler(enabled: true);
      addTearDown(scheduler.dispose);
      scheduler.start();
      await Future.delayed(_debounce * 2);
      clearInteractions(syncService);

      final completer = Completer<SyncRunResult>();
      when(() => syncService.runFullSync())
          .thenAnswer((_) => completer.future);

      final first = scheduler.syncNow();
      final second = scheduler.syncNow();
      final third = scheduler.syncNow();

      expect(scheduler.isSyncing.value, isTrue);
      completer.complete(_okResult);
      await Future.wait([first, second, third]);

      // Exactly one cycle ran for the concurrent callers, plus one coalesced
      // rerun (triggered by the 2nd/3rd calls) as a second iteration inside
      // that same cycle before the shared future resolves.
      await Future.delayed(Duration.zero);
      verify(() => syncService.runFullSync()).called(2);
    });

    test('a trigger arriving mid-cycle causes exactly one extra cycle',
        () async {
      when(() => authService.currentUser).thenReturn(FakeAuthUser());
      final scheduler = buildScheduler(enabled: true);
      addTearDown(scheduler.dispose);
      scheduler.start();
      await Future.delayed(_debounce * 2);
      clearInteractions(syncService);

      var calls = 0;
      final gate = <Completer<SyncRunResult>>[];
      when(() => syncService.runFullSync()).thenAnswer((_) {
        calls++;
        final completer = Completer<SyncRunResult>();
        gate.add(completer);
        return completer.future;
      });

      final firstCall = scheduler.syncNow();
      await Future.delayed(Duration.zero);
      expect(calls, 1);

      // Multiple triggers while the first cycle is still running.
      unawaited(scheduler.syncNow());
      unawaited(scheduler.syncNow());
      unawaited(scheduler.syncNow());

      gate[0].complete(_okResult);
      await Future.delayed(Duration.zero);

      // Only one coalesced rerun, not one per extra trigger.
      expect(calls, 2);
      expect(scheduler.isSyncing.value, isTrue);

      gate[1].complete(_okResult);
      await firstCall;
      expect(scheduler.isSyncing.value, isFalse);
    });
  });

  group('429 backoff', () {
    test('automatic triggers are suppressed during backoff, syncNow still runs',
        () async {
      when(() => authService.currentUser).thenReturn(FakeAuthUser());
      final scheduler = buildScheduler(enabled: true);
      addTearDown(scheduler.dispose);
      scheduler.start();
      await Future.delayed(_debounce * 2);
      clearInteractions(syncService);

      when(() => syncService.runFullSync()).thenThrow(
          QuizzyBackendException('rate limited', statusCode: 429));

      // Trigger a 429 via a direct syncNow() call (user-initiated calls
      // always run, even before backoff is armed).
      await scheduler.syncNow();
      clearInteractions(syncService);
      when(() => syncService.runFullSync()).thenAnswer((_) async => _okResult);

      // Automatic dirty-count trigger during the backoff window is
      // suppressed.
      dirtyDeckController.add(0); // swallowed by skip(1)
      await Future.delayed(Duration.zero);
      dirtyDeckController.add(1);
      await Future.delayed(_debounce * 2);
      verifyNever(() => syncService.runFullSync());

      // A direct syncNow() call still runs during backoff.
      await scheduler.syncNow();
      verify(() => syncService.runFullSync()).called(1);
    });

    test('backoff resets after one successful cycle', () async {
      when(() => authService.currentUser).thenReturn(FakeAuthUser());
      final scheduler = buildScheduler(enabled: true);
      addTearDown(scheduler.dispose);
      scheduler.start();
      await Future.delayed(_debounce * 2);
      clearInteractions(syncService);

      when(() => syncService.runFullSync()).thenThrow(
          QuizzyBackendException('rate limited', statusCode: 429));
      await scheduler.syncNow();

      when(() => syncService.runFullSync()).thenAnswer((_) async => _okResult);
      await scheduler.syncNow();
      clearInteractions(syncService);

      // After a success, an automatic trigger is no longer suppressed.
      dirtyDeckController.add(0); // swallowed by skip(1)
      await Future.delayed(Duration.zero);
      dirtyDeckController.add(1);
      await Future.delayed(_debounce * 2);

      verify(() => syncService.runFullSync()).called(1);
    });
  });
}
