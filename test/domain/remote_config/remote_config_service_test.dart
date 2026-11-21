import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class _MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

class _MockLogger extends Mock implements Logger {}

void main() {
  late _MockFirebaseRemoteConfig firebaseRemoteConfig;
  late RemoteConfigService service;

  setUp(() {
    firebaseRemoteConfig = _MockFirebaseRemoteConfig();
    service = RemoteConfigService(
      remoteConfig: firebaseRemoteConfig,
      logger: _MockLogger(),
    );
  });

  void stubByokModels(String json) =>
      when(() => firebaseRemoteConfig.getString('byok_models'))
          .thenReturn(json);

  test('parses apiKey and models per provider', () {
    stubByokModels('{"claude": {"apiKey": " sk-ant ", '
        '"models": ["claude-opus-4-8", "claude-opus-4-8", 1]}, '
        '"openAI": {"apiKey": "sk-oai"}}');

    final claude = service.byokModelsConfig(AnswerValidatorType.claude);
    expect(claude.apiKey, 'sk-ant');
    expect(claude.models, ['claude-opus-4-8']);

    final openAI = service.byokModelsConfig(AnswerValidatorType.openAI);
    expect(openAI.apiKey, 'sk-oai');
    expect(openAI.models, isEmpty);

    final gemini = service.byokModelsConfig(AnswerValidatorType.gemini);
    expect(gemini.apiKey, isNull);
    expect(gemini.models, isEmpty);
  });

  test('accepts a plain array as models only', () {
    stubByokModels('{"gemini": ["gemini-2.5-flash"]}');

    final gemini = service.byokModelsConfig(AnswerValidatorType.gemini);
    expect(gemini.apiKey, isNull);
    expect(gemini.models, ['gemini-2.5-flash']);
  });

  test('blank apiKey is treated as missing', () {
    stubByokModels('{"claude": {"apiKey": "  "}}');
    expect(service.byokModelsConfig(AnswerValidatorType.claude).apiKey,
        isNull);
  });

  test('malformed JSON returns empty config', () {
    stubByokModels('{not json');
    final config = service.byokModelsConfig(AnswerValidatorType.claude);
    expect(config.apiKey, isNull);
    expect(config.models, isEmpty);
  });

  test('non-object value returns empty config', () {
    stubByokModels('["claude-opus-4-8"]');
    expect(service.byokModelsConfig(AnswerValidatorType.claude).models,
        isEmpty);
  });
}
