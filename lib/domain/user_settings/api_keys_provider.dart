import 'dart:async';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';

class ApiKeysProvider {
  final UserRepository userRepository;
  final UserSettingsRepository userSettingsRepository;

  ApiKeysProvider({
    required this.userRepository,
    required this.userSettingsRepository,
  });

  String? _cachedGeminiApiKey;
  String? _cachedClaudeApiKey;
  String? _cachedOpenAiApiKey;
  StreamSubscription? _settingsSubscription;
  bool _initialized = false;

  /// Initializes the provider by watching user settings changes
  Future<void> initialize() async {
    if (_initialized) return;

    final currentUser = await userRepository.fetchCurrentUser();
    final settingsStream = userSettingsRepository.watchUserSettings(currentUser.id);

    _settingsSubscription = settingsStream.listen((settings) {
      _cachedGeminiApiKey = settings.geminiApiKey;
      _cachedClaudeApiKey = settings.claudeApiKey;
      _cachedOpenAiApiKey = settings.openAiApiKey;
    });

    _initialized = true;
  }

  /// Gets the cached Gemini API key
  String? get geminiApiKey => _cachedGeminiApiKey;

  /// Gets the cached Claude API key
  String? get claudeApiKey => _cachedClaudeApiKey;

  /// Gets the cached OpenAI API key
  String? get openAiApiKey => _cachedOpenAiApiKey;

  /// Disposes the provider and cancels subscriptions
  void dispose() {
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
    _initialized = false;
  }
}