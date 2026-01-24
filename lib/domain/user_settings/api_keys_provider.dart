import 'dart:async';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class ValidatorConfigProvider {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;

  ValidatorConfigProvider({
    required this.userRepository,
    required this.userSettingsRepository,
  });

  ValidatorConfig? _cachedGeminiConfig;
  ValidatorConfig? _cachedClaudeConfig;
  ValidatorConfig? _cachedOpenAiConfig;
  StreamSubscription? _settingsSubscription;
  bool _initialized = false;

  /// Initializes the provider by watching user settings changes
  Future<void> initialize() async {
    if (_initialized) return;

    final currentUser = await userRepository.fetchCurrentUser();
    final settings =
        await userSettingsRepository.fetchUserSettings(currentUser.id);

    _cachedGeminiConfig = settings.geminiConfig;
    _cachedClaudeConfig = settings.claudeConfig;
    _cachedOpenAiConfig = settings.openConfig;

    _settingsSubscription = userSettingsRepository
        .watchUserSettings(currentUser.id)
        .listen((updatedSettings) {
      _cachedGeminiConfig = updatedSettings.geminiConfig;
      _cachedClaudeConfig = updatedSettings.claudeConfig;
      _cachedOpenAiConfig = updatedSettings.openConfig;
    });

    _initialized = true;
  }

  /// Gets the cached Gemini API key
  ValidatorConfig? get geminiConfig => _cachedGeminiConfig;

  /// Gets the cached Claude API key
  ValidatorConfig? get claudeConfig => _cachedClaudeConfig;

  /// Gets the cached OpenAI API key
  ValidatorConfig? get openAiConfig => _cachedOpenAiConfig;

  /// Disposes the provider and cancels subscriptions
  void dispose() {
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
    _initialized = false;
  }
}
