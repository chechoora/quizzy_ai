import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/backup_scheduler.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_restore_service.dart';
import 'package:poc_ai_quiz/domain/onboarding/onboarding_service.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockDeckPremiumManager extends Mock implements DeckPremiumManager {}

class MockOnboardingService extends Mock implements OnboardingService {}

class MockICloudRestoreService extends Mock implements ICloudRestoreService {}

class MockBackupScheduler extends Mock implements BackupScheduler {}

void main() {
  late MockDeckRepository deckRepository;
  late MockDeckPremiumManager deckPremiumManager;
  late MockOnboardingService onboardingService;
  late MockICloudRestoreService iCloudRestoreService;
  late MockBackupScheduler backupScheduler;
  late HomeCubit cubit;

  setUp(() {
    deckRepository = MockDeckRepository();
    deckPremiumManager = MockDeckPremiumManager();
    onboardingService = MockOnboardingService();
    iCloudRestoreService = MockICloudRestoreService();
    backupScheduler = MockBackupScheduler();
    when(() => backupScheduler.start()).thenReturn(null);
    cubit = HomeCubit(
      deckRepository: deckRepository,
      deckPremiumManager: deckPremiumManager,
      onboardingService: onboardingService,
      iCloudRestoreService: iCloudRestoreService,
      backupScheduler: backupScheduler,
      isSubscriptionOnly: false,
    );
  });

  tearDown(() => cubit.close());

  group('checkOnboarding', () {
    test('emits ShowOnboardingState when onboarding is not completed',
        () async {
      when(() => onboardingService.isOnboardingCompleted())
          .thenAnswer((_) async => false);

      await cubit.checkOnboarding();

      expect(cubit.state, isA<ShowOnboardingState>());
    });

    test('emits nothing when onboarding is already completed', () async {
      when(() => onboardingService.isOnboardingCompleted())
          .thenAnswer((_) async => true);
      when(() => iCloudRestoreService.shouldOfferRestore())
          .thenAnswer((_) async => false);

      await cubit.checkOnboarding();

      expect(cubit.state, isA<DeckLoadingState>());
    });

    test(
        'starts the backup scheduler when onboarding is already completed '
        'and there is nothing to restore', () async {
      when(() => onboardingService.isOnboardingCompleted())
          .thenAnswer((_) async => true);
      when(() => iCloudRestoreService.shouldOfferRestore())
          .thenAnswer((_) async => false);

      await cubit.checkOnboarding();

      verify(() => backupScheduler.start()).called(1);
    });
  });

  group('checkICloudRestore', () {
    test('emits ShowICloudRestoreState and defers the backup scheduler '
        'when a restore should be offered', () async {
      when(() => iCloudRestoreService.shouldOfferRestore())
          .thenAnswer((_) async => true);
      when(() => iCloudRestoreService.markPromptShown())
          .thenAnswer((_) async {});

      await cubit.checkICloudRestore();

      expect(cubit.state, isA<ShowICloudRestoreState>());
      verifyNever(() => backupScheduler.start());
    });

    test('starts the backup scheduler when nothing should be offered',
        () async {
      when(() => iCloudRestoreService.shouldOfferRestore())
          .thenAnswer((_) async => false);

      await cubit.checkICloudRestore();

      verify(() => backupScheduler.start()).called(1);
    });
  });

  group('skipICloudRestore', () {
    test('starts the backup scheduler', () {
      cubit.skipICloudRestore();

      verify(() => backupScheduler.start()).called(1);
    });
  });

  group('restoreFromICloud', () {
    test('starts the backup scheduler after a successful restore', () async {
      when(() => iCloudRestoreService.restore()).thenAnswer((_) async => 3);

      await cubit.restoreFromICloud();

      expect(cubit.state, isA<ICloudRestoreSuccessState>());
      verify(() => backupScheduler.start()).called(1);
    });

    test('starts the backup scheduler even when restore fails', () async {
      when(() => iCloudRestoreService.restore())
          .thenThrow(Exception('boom'));

      await cubit.restoreFromICloud();

      expect(cubit.state, isA<ICloudRestoreErrorState>());
      verify(() => backupScheduler.start()).called(1);
    });
  });

  group('completeOnboarding', () {
    test('delegates to the onboarding service', () async {
      when(() => onboardingService.completeOnboarding())
          .thenAnswer((_) async {});

      await cubit.completeOnboarding();

      verify(() => onboardingService.completeOnboarding()).called(1);
    });
  });
}
