import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class RemoteConfigService {
  RemoteConfigService({
    required FirebaseRemoteConfig remoteConfig,
    required this.logger,
  }) : _remoteConfig = remoteConfig;

  final FirebaseRemoteConfig _remoteConfig;
  final Logger logger;

  static const _privacyPolicyKey = 'privacy_policy';
  static const _termsAndConditionsKey = 'terms_and_conditions';
  static const _defaultUrl = 'https://github.com/chechoora/quizzy_ai';

  static const _deckLimitKey = 'deck_limit';
  static const _quizCardLimitKey = 'quiz_card_limit';
  static const _defaultDeckLimit = 3;
  static const _defaultQuizCardLimit = 8;

  /// JSON object keyed by BYOK provider ([AnswerValidatorType.name]):
  /// ```json
  /// {"claude": {"apiKey": "sk-ant-...", "models": ["claude-opus-4-8"]}}
  /// ```
  /// `apiKey` (app-owned key used only to list the provider's models) and
  /// `models` (curated ids shown first in the dropdown) are both optional.
  /// A plain array value is accepted as `models` only.
  static const _byokModelsKey = 'byok_models';
  static const _defaultByokModels = '{}';

  Future<void> initialize() async {
    logger.d('initialize: starting');
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(const {
        _privacyPolicyKey: _defaultUrl,
        _termsAndConditionsKey: _defaultUrl,
        _deckLimitKey: _defaultDeckLimit,
        _quizCardLimitKey: _defaultQuizCardLimit,
        _byokModelsKey: _defaultByokModels,
      });
      await _remoteConfig.fetchAndActivate();
      logger.i('initialize: fetched and activated remote config');
    } catch (e, stacktrace) {
      logger.e('initialize: fetch failed, falling back to defaults',
          ex: e, stacktrace: stacktrace);
    }
  }

  String get privacyPolicyUrl => _remoteConfig.getString(_privacyPolicyKey);

  String get termsAndConditionsUrl =>
      _remoteConfig.getString(_termsAndConditionsKey);

  int get deckLimit => _remoteConfig.getInt(_deckLimitKey);

  int get quizCardLimit => _remoteConfig.getInt(_quizCardLimitKey);

  /// Model-list config for [type] from the `byok_models` parameter. Returns
  /// [ByokModelsConfig.empty] when the parameter is missing, malformed, or has
  /// no entry for [type].
  ByokModelsConfig byokModelsConfig(AnswerValidatorType type) {
    final raw = _remoteConfig.getString(_byokModelsKey);
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        logger.w('byokModelsConfig: $_byokModelsKey is not a JSON object');
        return ByokModelsConfig.empty;
      }
      final entry = decoded[type.name];
      if (entry is List) {
        return ByokModelsConfig(models: _stringList(entry));
      }
      if (entry is Map<String, dynamic>) {
        final apiKey = entry['apiKey'];
        final models = entry['models'];
        return ByokModelsConfig(
          apiKey: apiKey is String && apiKey.trim().isNotEmpty
              ? apiKey.trim()
              : null,
          models: models is List ? _stringList(models) : const [],
        );
      }
      return ByokModelsConfig.empty;
    } catch (e, stacktrace) {
      logger.e('byokModelsConfig: failed to parse $_byokModelsKey',
          ex: e, stacktrace: stacktrace);
      return ByokModelsConfig.empty;
    }
  }

  static List<String> _stringList(List<dynamic> values) =>
      values.whereType<String>().toSet().toList();
}

class ByokModelsConfig {
  const ByokModelsConfig({this.apiKey, this.models = const []});

  static const empty = ByokModelsConfig();

  /// App-owned API key used only to fetch the provider's model list.
  final String? apiKey;

  /// Curated model ids shown first in the dropdown.
  final List<String> models;
}
