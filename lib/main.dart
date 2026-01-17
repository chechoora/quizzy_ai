import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/util/app_theme.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/create_card/create_card_widget.dart';
import 'package:poc_ai_quiz/view/create_deck/create_deck_widget.dart';
import 'package:poc_ai_quiz/view/home_widget/home_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/quiz_card_list_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_exe_widget.dart';
import 'package:poc_ai_quiz/view/settings/premium_settings/premium_settings_widget.dart';
import 'package:fimber/fimber.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());
  await setupDi();
  runApp(MyApp());
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
          final quizCards = state.extra as List<QuizCardItem>;
          return QuizExeWidget(
            cards: quizCards,
          );
        },
      ),
      GoRoute(
        name: CreateDeckRoute().name,
        path: CreateDeckRoute().path,
        builder: (context, state) {
          final deckName = state.extra as String?;
          return CreateDeckWidget(
            deckName: deckName,
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
      )
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _routerConfig,
      theme: AppTheme.lightTheme,
    );
  }
}
