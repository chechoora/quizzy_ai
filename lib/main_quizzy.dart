import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/main.dart';

/// Entry point for the free / bring-your-own-key "Quizzy AI" flavor.
Future<void> main() => mainCommon(
      const AppConfig(
        appName: 'Quizzy AI',
        flavor: Flavor.quizzy,
        enableByok: true,
        requireAuth: false,
        enableIcloudBackup: true,
        isSubscriptionOnly: false,
        enableRemoteSync: false,
        enableAnalytics: false,
        backendSupported: false,
        sentryDsn: '',
      ),
    );
