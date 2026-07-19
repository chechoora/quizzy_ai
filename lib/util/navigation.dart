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

final class AuthRoute extends NavigationRoute {
  AuthRoute() : super(name: 'auth', path: '/auth');
}

final class QuizCardListRoute extends NavigationRoute {
  QuizCardListRoute() : super(name: 'quilCardList', path: '/quilCardList');
}

final class QuizExeRoute extends NavigationRoute {
  QuizExeRoute() : super(name: 'quizExe', path: '/quizExe');

  static const isQuickPlayKey = 'isQuickPlay';
  static const quizCardsKey = 'quizCards';
}

final class CreateDeckRoute extends NavigationRoute {
  CreateDeckRoute() : super(name: 'createDeck', path: '/createDeck');
}

final class CreateCardRoute extends NavigationRoute {
  CreateCardRoute() : super(name: 'createCard', path: '/createCard');
}

final class DeckEditRoute extends NavigationRoute {
  DeckEditRoute() : super(name: 'deckEdit', path: '/deckEdit');
}

final class SettingsInAppFeaturesRoute extends NavigationRoute {
  SettingsInAppFeaturesRoute() : super(name: 'inAppFeatures', path: '/inAppFeatures');
}

final class SettingsImportExportRoute extends NavigationRoute {
  SettingsImportExportRoute()
      : super(name: 'importExport', path: '/importExport');
}

final class SettingsAIValidatorRoute extends NavigationRoute {
  SettingsAIValidatorRoute()
      : super(name: 'settingsAIValidator', path: '/settingsAIValidator');
}

final class SettingsDeckGenerationRoute extends NavigationRoute {
  SettingsDeckGenerationRoute()
      : super(
            name: 'settingsDeckGeneration', path: '/settingsDeckGeneration');
}

final class AppCreditsRoute extends NavigationRoute {
  AppCreditsRoute() : super(name: 'appCredits', path: '/appCredits');
}
