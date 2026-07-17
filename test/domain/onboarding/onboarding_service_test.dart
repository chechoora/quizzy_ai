import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/onboarding/onboarding_service.dart';
import 'package:poc_ai_quiz/domain/user/model/user_item.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

void main() {
  late MockUserRepository userRepository;
  late MockUserSettingsRepository userSettingsRepository;
  late OnboardingService service;

  setUp(() {
    userRepository = MockUserRepository();
    userSettingsRepository = MockUserSettingsRepository();
    service = OnboardingService(
      userRepository: userRepository,
      userSettingsRepository: userSettingsRepository,
    );

    when(() => userRepository.fetchCurrentUser())
        .thenAnswer((_) async => UserItem(42));
  });

  group('OnboardingService', () {
    test('isOnboardingCompleted reads the flag for the current user', () async {
      when(() => userSettingsRepository.isOnboardingCompleted(42))
          .thenAnswer((_) async => true);

      expect(await service.isOnboardingCompleted(), isTrue);
      verify(() => userSettingsRepository.isOnboardingCompleted(42)).called(1);
    });

    test('isOnboardingCompleted returns false when not completed', () async {
      when(() => userSettingsRepository.isOnboardingCompleted(42))
          .thenAnswer((_) async => false);

      expect(await service.isOnboardingCompleted(), isFalse);
    });

    test('completeOnboarding writes the flag for the current user', () async {
      when(() => userSettingsRepository.setOnboardingCompleted(42))
          .thenAnswer((_) async {});

      await service.completeOnboarding();

      verify(() => userSettingsRepository.setOnboardingCompleted(42)).called(1);
    });
  });
}
