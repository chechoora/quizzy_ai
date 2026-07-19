import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class OnboardingService {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;

  OnboardingService({
    required this.userRepository,
    required this.userSettingsRepository,
  });

  Future<bool> isOnboardingCompleted() async {
    final user = await userRepository.fetchCurrentUser();
    return userSettingsRepository.isOnboardingCompleted(user.id);
  }

  Future<void> completeOnboarding() async {
    final user = await userRepository.fetchCurrentUser();
    await userSettingsRepository.setOnboardingCompleted(user.id);
  }
}
