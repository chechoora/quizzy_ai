import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_api_service.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';
import 'package:poc_ai_quiz/domain/settings/ai_models_repository.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockClaude extends Mock implements ClaudeModelsApiService {}

class _MockOpenAI extends Mock implements OpenAIModelsApiService {}

class _MockGemini extends Mock implements GeminiApiService {}

class _MockConfigProvider extends Mock implements ValidatorConfigProvider {}

class _MockLogger extends Mock implements Logger {}

class _MockRemoteConfig extends Mock implements RemoteConfigService {}

Response<dynamic> _response(int status, Object? body) =>
    Response<dynamic>(http.Response('', status), body);

void main() {
  setUpAll(() => registerFallbackValue(AnswerValidatorType.claude));

  late _MockClaude claude;
  late _MockOpenAI openAI;
  late _MockGemini gemini;
  late _MockConfigProvider configProvider;
  late _MockRemoteConfig remoteConfig;
  late SharedPreferences prefs;
  late DateTime now;

  AiModelsRepository buildRepo() => AiModelsRepository(
        claudeModelsApiService: claude,
        openAIModelsApiService: openAI,
        geminiApiService: gemini,
        validatorConfigProvider: configProvider,
        remoteConfigService: remoteConfig,
        prefs: prefs,
        logger: _MockLogger(),
        clock: () => now,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    claude = _MockClaude();
    openAI = _MockOpenAI();
    gemini = _MockGemini();
    configProvider = _MockConfigProvider();
    remoteConfig = _MockRemoteConfig();
    when(() => remoteConfig.byokModelsConfig(any()))
        .thenReturn(ByokModelsConfig.empty);
    now = DateTime(2026, 11, 21, 12);
    when(() => configProvider.claudeConfig)
        .thenReturn(const ApiKeyConfig(apiKey: 'sk-ant', model: 'm'));
    when(() => configProvider.openAiConfig)
        .thenReturn(const ApiKeyConfig(apiKey: 'sk-oai', model: 'm'));
    when(() => configProvider.geminiConfig)
        .thenReturn(const ApiKeyConfig(apiKey: 'g-key', model: 'm'));
  });

  final claudeBody = {
    'data': [
      {'id': 'claude-opus-4-8'},
      {'id': 'claude-sonnet-4-6'},
    ],
  };

  test('returns curated models without network when no API key saved',
      () async {
    when(() => configProvider.claudeConfig).thenReturn(ApiKeyConfig.empty());
    when(() => remoteConfig.byokModelsConfig(AnswerValidatorType.claude))
        .thenReturn(ByokModelsConfig(models: ['claude-opus-4-8', 'claude-haiku-4-5']));

    expect(await buildRepo().getModels(AnswerValidatorType.claude),
        ['claude-opus-4-8', 'claude-haiku-4-5']);
    verifyNever(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')));
  });

  test('without user key, fetches with the app key from Remote Config',
      () async {
    when(() => configProvider.claudeConfig).thenReturn(ApiKeyConfig.empty());
    when(() => remoteConfig.byokModelsConfig(AnswerValidatorType.claude))
        .thenReturn(const ByokModelsConfig(
            apiKey: 'app-key', models: ['claude-haiku-4-5']));
    when(() => claude.listModels(
            apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));

    expect(await buildRepo().getModels(AnswerValidatorType.claude),
        ['claude-haiku-4-5', 'claude-opus-4-8', 'claude-sonnet-4-6']);
    verify(() => claude.listModels(
        apiKey: 'app-key', limit: any(named: 'limit'))).called(1);
  });

  test('user key takes precedence over the app key', () async {
    when(() => remoteConfig.byokModelsConfig(AnswerValidatorType.claude))
        .thenReturn(const ByokModelsConfig(apiKey: 'app-key'));
    when(() => claude.listModels(
            apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));

    await buildRepo().getModels(AnswerValidatorType.claude);
    verify(() => claude.listModels(
        apiKey: 'sk-ant', limit: any(named: 'limit'))).called(1);
  });

  test('returns empty list when no API key and no curated models', () async {
    when(() => configProvider.claudeConfig).thenReturn(ApiKeyConfig.empty());

    expect(await buildRepo().getModels(AnswerValidatorType.claude), isEmpty);
  });

  test('with API key: curated first, then live extras, deduped', () async {
    when(() => remoteConfig.byokModelsConfig(AnswerValidatorType.claude))
        .thenReturn(ByokModelsConfig(models: ['claude-sonnet-4-6', 'claude-haiku-4-5']));
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));

    expect(await buildRepo().getModels(AnswerValidatorType.claude),
        ['claude-sonnet-4-6', 'claude-haiku-4-5', 'claude-opus-4-8']);
  });

  test('with API key: live fetch failure still returns curated', () async {
    when(() => remoteConfig.byokModelsConfig(AnswerValidatorType.claude))
        .thenReturn(ByokModelsConfig(models: ['claude-sonnet-4-6']));
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(500, null));

    expect(await buildRepo().getModels(AnswerValidatorType.claude),
        ['claude-sonnet-4-6']);
  });

  test('fetches, caches, and serves fresh cache without network', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));
    final repo = buildRepo();

    expect(await repo.getModels(AnswerValidatorType.claude),
        ['claude-opus-4-8', 'claude-sonnet-4-6']);
    now = now.add(const Duration(hours: 1));
    expect(await repo.getModels(AnswerValidatorType.claude),
        ['claude-opus-4-8', 'claude-sonnet-4-6']);
    verify(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit'))).called(1);
  });

  test('refetches when cache is stale', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));
    final repo = buildRepo();
    await repo.getModels(AnswerValidatorType.claude);

    now = now.add(const Duration(hours: 25));
    await repo.getModels(AnswerValidatorType.claude);
    verify(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit'))).called(2);
  });

  test('server error falls back to stale cache', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));
    final repo = buildRepo();
    await repo.getModels(AnswerValidatorType.claude);

    now = now.add(const Duration(hours: 25));
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(500, null));
    expect(await repo.getModels(AnswerValidatorType.claude),
        ['claude-opus-4-8', 'claude-sonnet-4-6']);
  });

  test('server error without cache returns empty list', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(401, null));
    expect(await buildRepo().getModels(AnswerValidatorType.claude), isEmpty);
  });

  test('exception without cache returns empty list', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenThrow(Exception('offline'));
    expect(await buildRepo().getModels(AnswerValidatorType.claude), isEmpty);
  });

  test('cache is scoped to the API key', () async {
    when(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit')))
        .thenAnswer((_) async => _response(200, claudeBody));
    final repo = buildRepo();
    await repo.getModels(AnswerValidatorType.claude);

    when(() => configProvider.claudeConfig)
        .thenReturn(const ApiKeyConfig(apiKey: 'other-key', model: 'm'));
    await repo.getModels(AnswerValidatorType.claude);
    verify(() => claude.listModels(apiKey: any(named: 'apiKey'), limit: any(named: 'limit'))).called(2);
    expect(prefs.getKeys().every((k) => !k.contains('sk-ant')), isTrue);
  });

  test('OpenAI keeps chat models only, newest first', () {
    final models = AiModelsRepository.parseOpenAIModels({
      'data': [
        {'id': 'gpt-4o-mini'},
        {'id': 'text-embedding-3-small'},
        {'id': 'gpt-4o-realtime-preview'},
        {'id': 'o3-mini'},
        {'id': 'whisper-1'},
        {'id': 'gpt-5'},
        {'id': 'dall-e-3'},
        {'id': 'gpt-4o-mini-tts'},
      ],
    });
    expect(models, ['o3-mini', 'gpt-5', 'gpt-4o-mini']);
  });

  test('Gemini keeps generateContent models and strips models/ prefix', () {
    final models = AiModelsRepository.parseGeminiModels({
      'models': [
        {
          'name': 'models/gemini-2.5-flash',
          'supportedGenerationMethods': ['generateContent', 'countTokens'],
        },
        {
          'name': 'models/text-embedding-004',
          'supportedGenerationMethods': ['embedContent'],
        },
      ],
    });
    expect(models, ['gemini-2.5-flash']);
  });
}
