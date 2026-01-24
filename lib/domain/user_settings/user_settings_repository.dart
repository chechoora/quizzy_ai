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

  Future<ApiKeyConfig?> getGeminiApiKey(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.geminiConfig;
  }

  Future<void> setGeminiApiKey(int userId, String? apiKey) async {
    await dataBaseRepository.updateGeminiApiKey(userId, apiKey);
  }

  Future<ApiKeyConfig?> getClaudeApiKey(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.claudeConfig;
  }

  Future<void> setClaudeApiKey(int userId, String? apiKey) async {
    await dataBaseRepository.updateClaudeApiKey(userId, apiKey);
  }

  Future<ApiKeyConfig?> getOpenAiApiKey(int userId) async {
    final settings = await fetchUserSettings(userId);
    return settings.openConfig;
  }

  Future<void> setOpenAiApiKey(int userId, String? apiKey) async {
    await dataBaseRepository.updateOpenAiApiKey(userId, apiKey);
  }
}