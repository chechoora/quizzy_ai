import 'package:poc_ai_quiz/data/db/user_settings/user_settings_database_repository.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/model/user_settings_item.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_database_mapper.dart';

class UserSettingsRepository {
  final UserSettingsDataBaseRepository dataBaseRepository;
  final UserSettingsDataBaseMapper userSettingsDataBaseMapper;

  UserSettingsRepository({
    required this.dataBaseRepository,
    required this.userSettingsDataBaseMapper,
  });

  Future<UserSettingsItem> fetchUserSettings(int userId) async {
    final dbUserSettings = await dataBaseRepository.fetchUserSettings(userId);
    return userSettingsDataBaseMapper.mapToUserSettingsItem(dbUserSettings);
  }

  Stream<UserSettingsItem> watchUserSettings(int userId) {
    return dataBaseRepository.watchUserSettings(userId).map(
      (dbUserSettings) => userSettingsDataBaseMapper.mapToUserSettingsItem(dbUserSettings),
    );
  }

  Future<void> updateAnswerValidatorType(int userId, AnswerValidatorType validatorType) async {
    await dataBaseRepository.updateAnswerValidatorType(userId, validatorType.name);
  }

  Future<void> updateDeckGenerationAiType(
      int userId, AnswerValidatorType type) async {
    await dataBaseRepository.updateDeckGenerationAiType(userId, type.name);
  }

  Future<ApiKeyConfig?> getGeminiConfig(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.geminiConfig;
  }

  Future<void> setGeminiConfig(int userId, ApiKeyConfig? config) async {
    await dataBaseRepository.updateGeminiConfig(
      userId,
      config?.apiKey,
      config?.model,
    );
  }

  Future<ApiKeyConfig?> getClaudeConfig(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.claudeConfig;
  }

  Future<void> setClaudeConfig(int userId, ApiKeyConfig? config) async {
    await dataBaseRepository.updateClaudeConfig(
      userId,
      config?.apiKey,
      config?.model,
    );
  }

  Future<ApiKeyConfig?> getOpenAiConfig(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.openConfig;
  }

  Future<void> setOpenAiConfig(int userId, ApiKeyConfig? config) async {
    await dataBaseRepository.updateOpenAiConfig(
      userId,
      config?.apiKey,
      config?.model,
    );
  }

  Future<void> setOllamaConfig(int userId, OpenSourceConfig? config) async {
    await dataBaseRepository.updateOllamaConfig(userId, config?.url, config?.model);
  }
}