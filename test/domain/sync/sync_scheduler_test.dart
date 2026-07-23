import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/domain/sync/model/sync_result.dart';
import 'package:poc_ai_quiz/domain/sync/sync_scheduler.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockDeckCardSyncService extends Mock implements DeckCardSyncService {}

class MockAuthService extends Mock implements AuthService {}

class FakeAuthUser extends Fake implements AuthUser {}

const _debounce = Duration(milliseconds: 20);
const _pullInterval = Duration(hours: 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockDeckCardSyncService syncService;
  late MockAuthService authService;
  late StreamController<List<DeckItem>> deckController;
  late StreamController<List<QuizCardItem>> cardController;
  late StreamController<AuthUser?> authController;
  late ValueNotifier<bool> isSyncingNotifier;

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    syncService = MockDeckCardSyncService();
    authService = MockAuthService();
    deckController = StreamController<List<DeckItem>>.broadcast();
    cardController = StreamController<List<QuizCardItem>>.broadcast();
    authController = StreamController<AuthUser?>.broadcast();
    isSyncingNotifier = ValueNotifier<bool>(false);

    when(() => deckRepository.watchDecks())
        .thenAnswer((_) => deckController.stream);
    when(() => quizCardRepository.watchCards())
        .thenAnswer((_) => cardController.stream);
    when(() => authService.authStateChanges)
        .thenAnswer((_) => authController.stream);
    when(() => syncService.isSyncing).thenReturn(isSyncingNotifier);
    when(() => syncService.runFullSync()).thenAnswer((_) async =>
        const SyncRunResult(push: SyncPushResult(), pull: SyncPullResult()));
  });

  tearDown(() async {
    await deckController.close();
    await cardController.close();
    await authController.close();
    isSyncingNotifier.dispose();
  });

  SyncScheduler buildScheduler({required bool enabled}) {
    return SyncScheduler(
      deckRepository: deckRepository,
      quizCardRepository: quizCardRepository,
      syncService: syncService,
      authService: authService,
      logger: Logger.withTag('test'),
      enabled: enabled,
      debounce: _debounce,
      pullInterval: _pullInterval,
    );
  }

  test('start() no-ops when disabled', () async {
    when(() => authService.currentUser).thenReturn(null);
    final scheduler = buildScheduler(enabled: false);
    addTearDown(scheduler.dispose);

    scheduler.start();
    await Future.delayed(_debounce * 2);

    verifyNever(() => syncService.runFullSync());
  });

  test('a burst of local changes coalesces into one sync call', () async {
    when(() => authService.currentUser).thenReturn(FakeAuthUser());
    final scheduler = buildScheduler(enabled: true);
    addTearDown(scheduler.dispose);

    scheduler.start();
    // Let the "already signed in at start" initial sync fire and settle,
    // then stop counting it.
    await Future.delayed(_debounce * 2);
    clearInteractions(syncService);

    // First post-subscription event is swallowed by watchDecks().skip(1).
    deckController.add(const []);
    await Future.delayed(Duration.zero);

    // A burst of edits should coalesce into a single debounced sync.
    deckController.add(const []);
    deckController.add(const []);
    deckController.add(const []);
    await Future.delayed(_debounce * 2);

    verify(() => syncService.runFullSync()).called(1);
  });

  test('sync is skipped while signed out and fires once on sign-in',
      () async {
    when(() => authService.currentUser).thenReturn(null);
    final scheduler = buildScheduler(enabled: true);
    addTearDown(scheduler.dispose);

    scheduler.start();
    await Future.delayed(Duration.zero);

    // Swallowed by skip(1).
    deckController.add(const []);
    await Future.delayed(Duration.zero);

    // A local change while signed out must not trigger a sync.
    deckController.add(const []);
    await Future.delayed(_debounce * 2);
    verifyNever(() => syncService.runFullSync());

    // Signing in triggers exactly one sync.
    authController.add(FakeAuthUser());
    await Future.delayed(_debounce * 2);

    verify(() => syncService.runFullSync()).called(1);
  });
}
