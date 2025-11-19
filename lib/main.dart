import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
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
  MyApp({super.key});x

  final _routerConfig = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'home',
        // Optional, add name to your routes. Allows you navigate by name instead of path
        path: '/',
        builder: (context, state) {
          return const HomeWidget();
        },
        routes: [
          GoRoute(
            name: 'quizCardList',
            path: 'quizCardList',
            builder: (context, state) {
              final deckItem = state.extra as DeckItem;
              return QuizCardListWidget(deckItem: deckItem);
            },
          ),
        ],
      ),
      GoRoute(
        name: 'quizExe',
        path: '/quizExe',
        builder: (context, state) {
          final quizCards = state.extra as List<QuizCardItem>;
          return QuizExeWidget(
            cards: quizCards,
          );
        },
      ),
      GoRoute(
        name: 'premiumSettings',
        path: '/premiumSettings',
        builder: (context, state) {
          return const PremiumSettingsWidget();
        },
      ),
      GoRoute(
        name: 'createDeck',
        path: '/createDeck',
        builder: (context, state) {
          final deckName = state.extra as String?;
          return CreateDeckWidget(
            deckName: deckName,
          );
        },
      ),
      GoRoute(
        name: 'createCard',
        path: '/createCard',
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
      title: 'Flutter Demo',
      routerConfig: _routerConfig,
    );
  }
}
