import 'package:firebase_remote_config/firebase_remote_config.dart';
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
}
