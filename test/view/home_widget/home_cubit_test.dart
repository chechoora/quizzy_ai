import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/onboarding/onboarding_service.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockDeckPremiumManager extends Mock implements DeckPremiumManager {}

class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  late MockDeckRepository deckRepository;
  late MockDeckPremiumManager deckPremiumManager;
  late MockOnboardingService onboardingService;
  late HomeCubit cubit;

  setUp(() {
    deckRepository = MockDeckRepository();
    deckPremiumManager = MockDeckPremiumManager();
    onboardingService = MockOnboardingService();
    cubit = HomeCubit(
      deckRepository: deckRepository,
      deckPremiumManager: deckPremiumManager,
      onboardingService: onboardingService,
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

      await cubit.checkOnboarding();

      expect(cubit.state, isA<DeckLoadingState>());
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
