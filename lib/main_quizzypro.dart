import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/main.dart';

/// Entry point for the future subscription-only "Quizzy AI Pro" flavor.
Future<void> main() => mainCommon(
      const AppConfig(
        appName: 'Quizzy AI Pro',
        flavor: Flavor.quizzyPro,
        enableByok: false,
        requireAuth: true,
      ),
    );
