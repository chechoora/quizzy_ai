sealed class NavigationRoute {
  final String name;
  final String path;

  NavigationRoute({
    required this.name,
    required this.path,
  });
}

final class HomeRoute extends NavigationRoute {
  HomeRoute() : super(name: 'home', path: '/');
}

final class QuizExeRoute extends NavigationRoute {
  QuizExeRoute() : super(name: 'quizExe', path: '/quizExe');
}

final class CreateDeckRoute extends NavigationRoute {
  CreateDeckRoute() : super(name: 'createDeck', path: '/createDeck');
}

final class CreateCardRoute extends NavigationRoute {
  CreateCardRoute() : super(name: 'createCard', path: '/createCard');
}
