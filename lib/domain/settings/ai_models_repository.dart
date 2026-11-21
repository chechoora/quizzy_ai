import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_api_service.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model ids offered in the model dropdown of a BYOK provider
/// (Claude / OpenAI / Gemini).
///
/// The curated list from Remote Config (`byok_models`) comes first, followed
/// by the provider's live model list (cached in [SharedPreferences]). The live
/// list is fetched with the user's saved API key when there is one, otherwise
/// with the app-owned key from Remote Config — so it works before the user
/// entered a key.
///
/// Never throws: on any failure the live part falls back to a (possibly
/// stale) cached list, or is dropped — if nothing is left the UI simply hides
/// the model dropdown.
class AiModelsRepository {
  AiModelsRepository({
    required this.claudeModelsApiService,
    required this.openAIModelsApiService,
    required this.geminiApiService,
    required this.validatorConfigProvider,
    required this.remoteConfigService,
    required this.prefs,
    required this.logger,
    DateTime Function()? clock,
    this.cacheTtl = const Duration(hours: 24),
  }) : _clock = clock ?? DateTime.now;

  final ClaudeModelsApiService claudeModelsApiService;
  final OpenAIModelsApiService openAIModelsApiService;
  final GeminiApiService geminiApiService;
  final ValidatorConfigProvider validatorConfigProvider;
  final RemoteConfigService remoteConfigService;
  final SharedPreferences prefs;
  final Logger logger;
  final Duration cacheTtl;
  final DateTime Function() _clock;

  static const _cacheKeyPrefix = 'ai_models_';

  Future<List<String>> getModels(AnswerValidatorType type) async {
    logger.d('getModels: type=${type.name}');
    final remote = remoteConfigService.byokModelsConfig(type);
    final curated = remote.models;
    final userApiKey = _userApiKeyFor(type);
    final hasUserKey = userApiKey != null && userApiKey.isNotEmpty;
    final apiKey = hasUserKey ? userApiKey : remote.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      logger.d('getModels: no API key for ${type.name}, '
          'returning ${curated.length} curated models');
      return curated;
    }
    logger.d('getModels: listing ${type.name} models with '
        '${hasUserKey ? 'user' : 'app'} key');
    final live = await _getLiveModels(type, apiKey);
    return {...curated, ...live}.toList();
  }

  Future<List<String>> _getLiveModels(
    AnswerValidatorType type,
    String apiKey,
  ) async {

    final cacheKey = '$_cacheKeyPrefix${type.name}_${_fnv1a(apiKey)}';
    final cached = _readCache(cacheKey);
    if (cached != null &&
        _clock().difference(cached.fetchedAt) < cacheTtl &&
        cached.models.isNotEmpty) {
      logger.d('_getLiveModels: cache hit for ${type.name} '
          '(${cached.models.length} models)');
      return cached.models;
    }

    try {
      final models = await _fetch(type, apiKey);
      if (models == null) {
        logger.w('_getLiveModels: failed to fetch models for ${type.name}, '
            'using ${cached == null ? 'no' : 'stale'} cache');
        return cached?.models ?? const [];
      }
      await prefs.setString(
        cacheKey,
        jsonEncode({
          'fetchedAt': _clock().toIso8601String(),
          'models': models,
        }),
      );
      logger.i('Fetched ${models.length} models for ${type.name}');
      return models;
    } catch (e, stackTrace) {
      logger.e('_getLiveModels: error fetching models for ${type.name}',
          ex: e, stacktrace: stackTrace);
      return cached?.models ?? const [];
    }
  }

  String? _userApiKeyFor(AnswerValidatorType type) {
    final config = switch (type) {
      AnswerValidatorType.claude => validatorConfigProvider.claudeConfig,
      AnswerValidatorType.openAI => validatorConfigProvider.openAiConfig,
      AnswerValidatorType.gemini => validatorConfigProvider.geminiConfig,
      _ => null,
    };
    return config is ApiKeyConfig ? config.apiKey : null;
  }

  /// Returns the parsed model ids, or `null` when the server responded with an
  /// error.
  Future<List<String>?> _fetch(AnswerValidatorType type, String apiKey) async {
    final Response response = switch (type) {
      AnswerValidatorType.claude =>
        await claudeModelsApiService.listModels(apiKey: apiKey),
      AnswerValidatorType.openAI => await openAIModelsApiService.listModels(
          authorization: 'Bearer $apiKey'),
      AnswerValidatorType.gemini =>
        await geminiApiService.listModels(apiKey: apiKey),
      _ => throw ArgumentError('$type has no model list'),
    };
    if (!response.isSuccessful) {
      logger.w('_fetch: ${type.name} responded ${response.statusCode}');
      return null;
    }
    final body = response.body;
    if (body is! Map<String, dynamic>) {
      logger.w('_fetch: unexpected ${type.name} response shape');
      return null;
    }
    return switch (type) {
      AnswerValidatorType.claude => parseClaudeModels(body),
      AnswerValidatorType.openAI => parseOpenAIModels(body),
      AnswerValidatorType.gemini => parseGeminiModels(body),
      _ => const [],
    };
  }

  _CachedModels? _readCache(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _CachedModels(
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        models: (json['models'] as List).cast<String>(),
      );
    } catch (e, stackTrace) {
      logger.e('_readCache: corrupted cache entry, ignoring',
          ex: e, stacktrace: stackTrace);
      return null;
    }
  }

  static List<String> parseClaudeModels(Map<String, dynamic> body) =>
      _dedupe(_ids(body['data']));

  static final _openAIChatPrefix = RegExp(r'^(gpt-|chatgpt-|o\d)');
  static const _openAIExcluded = [
    'embedding',
    'tts',
    'whisper',
    'dall-e',
    'audio',
    'realtime',
    'transcribe',
    'image',
    'moderation',
    'search',
  ];

  static List<String> parseOpenAIModels(Map<String, dynamic> body) {
    final ids = _ids(body['data']).where((id) =>
        _openAIChatPrefix.hasMatch(id) &&
        !_openAIExcluded.any((ex) => id.contains(ex)));
    // OpenAI doesn't guarantee ordering; sort so newer versions come first.
    return _dedupe(ids)..sort((a, b) => b.compareTo(a));
  }

  static List<String> parseGeminiModels(Map<String, dynamic> body) {
    final models = body['models'];
    if (models is! List) return const [];
    final ids = models
        .whereType<Map<String, dynamic>>()
        .where((m) =>
            (m['supportedGenerationMethods'] as List?)
                ?.contains('generateContent') ??
            false)
        .map((m) => m['name'])
        .whereType<String>()
        .map((name) =>
            name.startsWith('models/') ? name.substring(7) : name);
    return _dedupe(ids);
  }

  static Iterable<String> _ids(Object? data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((m) => m['id'])
        .whereType<String>();
  }

  static List<String> _dedupe(Iterable<String> ids) => ids.toSet().toList();

  /// Stable 32-bit FNV-1a hash so the cache is scoped to the API key without
  /// persisting the key itself.
  static String _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(input)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }
}

class _CachedModels {
  const _CachedModels({required this.fetchedAt, required this.models});

  final DateTime fetchedAt;
  final List<String> models;
}
