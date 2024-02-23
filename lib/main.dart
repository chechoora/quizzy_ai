import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/view/deck_widget/deck_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/quiz_card_list_widget.dart';

Future<void> main() async {
  await setupDi();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _routerConfig = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
          name: 'home', // Optional, add name to your routes. Allows you navigate by name instead of path
          path: '/',
          builder: (context, state) {
            return const DeckWidget();
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
          ]),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        useMaterial3: true,
      ),
      routerConfig: _routerConfig,
    );
  }
}
