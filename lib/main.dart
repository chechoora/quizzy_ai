import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/util/app_theme.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/create_card/create_card_widget.dart';
import 'package:poc_ai_quiz/view/home_widget/home_widget.dart';
import 'package:poc_ai_quiz/view/import_export/screen.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/quiz_card_list_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_exe_widget.dart';
import 'package:poc_ai_quiz/view/settings/in_app_features/in_app_features_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/settings_ai_validator_widget.dart';
import 'package:fimber/fimber.dart';
import 'firebase_options.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    Fimber.plantTree(DebugTree());

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Disable Crashlytics in debug mode
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch Flutter framework errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch async errors outside Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await setupDi();
    runApp(MyApp());
  } catch (e, stackTrace) {
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
    }
    runApp(ErrorApp(error: e.toString(), stackTrace: stackTrace.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const ErrorApp({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[900],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STARTUP CRASH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error:',
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
                SelectableText(
                  error,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
                SelectableText(
                  stackTrace,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _routerConfig = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: HomeRoute().name,
        // Optional, add name to your routes. Allows you navigate by name instead of path
        path: HomeRoute().path,
        builder: (context, state) {
          return const HomeWidget();
        },
      ),
      GoRoute(
        name: QuizExeRoute().name,
        path: QuizExeRoute().path,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final quizCards =
              extras[QuizExeRoute.quizCardsKey] as List<QuizCardItem>;
          final isQuickPlay = extras[QuizExeRoute.isQuickPlayKey] as bool;
          return QuizExeWidget(cards: quizCards, isQuickPlay: isQuickPlay);
        },
      ),
      GoRoute(
        name: QuizCardListRoute().name,
        path: QuizCardListRoute().path,
        builder: (context, state) {
          final deckItem = state.extra as DeckItem;
          return QuizCardListWidget(
            deckItem: deckItem,
          );
        },
      ),
      GoRoute(
        name: CreateCardRoute().name,
        path: CreateCardRoute().path,
        builder: (context, state) {
          final card = state.extra as QuizCardItem?;
          return CreateCardWidget(
            cardToEdit: card,
          );
        },
      ),
      GoRoute(
        name: SettingsInAppFeaturesRoute().name,
        path: SettingsInAppFeaturesRoute().path,
        builder: (context, state) {
          return const SettingsInAppFeaturesWidget();
        },
      ),
      GoRoute(
        name: SettingsAIValidatorRoute().name,
        path: SettingsAIValidatorRoute().path,
        builder: (context, state) {
          return const SettingsAIValidatorWidget();
        },
      ),
      GoRoute(
        name: SettingsImportExportRoute().name,
        path: SettingsImportExportRoute().path,
        builder: (context, state) {
          return const ImportExportScreen();
        },
      ),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _routerConfig,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
