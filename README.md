# AI Quiz

A Flutter quiz application with AI-powered answer validation. Create flashcard decks, take quizzes, and get intelligent feedback on your answers using multiple AI providers.

## Features

- **Deck Management**: Create and organize quiz card decks
- **Quiz Cards**: Add questions and answers to your decks
- **AI Answer Validation**: Get your answers evaluated by AI with detailed feedback
  - Score (0-100)
  - Explanation of correctness
  - Correct points identified
  - Missing points highlighted
- **Multiple AI Providers**:
  - Google Gemini
  - Anthropic Claude
  - OpenAI GPT
  - On-device AI (offline)
- **Premium Features**: Unlock additional capabilities via in-app purchases
- **Local Storage**: All data stored locally using SQLite

## Requirements

- Flutter SDK 3.1.0+
- [FVM](https://fvm.app/) (Flutter Version Manager)
- API keys for AI providers (optional, depending on which validator you use)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd poc_ai_quiz
   ```

2. Install dependencies:
   ```bash
   fvm flutter pub get
   ```

3. Generate required code:
   ```bash
   fvm flutter packages pub run build_runner build
   ```

4. Run the app (pick a flavor — see [Flavors](#flavors)):
   ```bash
   fvm flutter run --flavor quizzy -t lib/main_quizzy.dart
   ```

## Flavors

The app is built in two flavors from the same codebase:

| Flavor      | App name       | Android applicationId        | Entry point                 |
|-------------|----------------|------------------------------|-----------------------------|
| `quizzy`    | Quizzy AI      | `com.chechoora.quizzy`       | `lib/main_quizzy.dart`      |
| `quizzypro` | Quizzy AI Pro  | `com.chechoora.quizzy.pro`   | `lib/main_quizzypro.dart`   |

Always pass both `--flavor` and the matching `-t` entry point:

```bash
# Run
fvm flutter run   --flavor quizzy    -t lib/main_quizzy.dart
fvm flutter run   --flavor quizzypro -t lib/main_quizzypro.dart

# Build (Android)
fvm flutter build apk --flavor quizzy    -t lib/main_quizzy.dart --debug
fvm flutter build apk --flavor quizzypro -t lib/main_quizzypro.dart --debug

# Build (iOS)
fvm flutter build ios --flavor quizzy    -t lib/main_quizzy.dart --debug --no-codesign
fvm flutter build ios --flavor quizzypro -t lib/main_quizzypro.dart --debug --no-codesign

# Build (Android App Bundle, release — for Play Store)
fvm flutter build appbundle --flavor quizzy    -t lib/main_quizzy.dart --release
fvm flutter build appbundle --flavor quizzypro -t lib/main_quizzypro.dart --release
```

> **Release signing:** Android release builds are signed using
> `android/release_key.properties` (keystore path + credentials, gitignored).
> It must exist before running the `appbundle --release` commands above.

> **quizzypro Firebase setup:** the Pro flavor uses a separate Firebase app
> (`com.chechoora.quizzy.pro`) under the same "Quizzy AI" project. Before it can
> build, add `android/app/src/quizzypro/google-services.json` and
> `ios/config/quizzypro/GoogleService-Info.plist` (see the READMEs in those
> folders).

### Versioned release builds

`quizzy` and `quizzypro` are versioned independently — pass `--build-name=<version>`
and `--build-number=<build>` on the CLI for every release build (omitting them falls
back to `pubspec.yaml`'s shared `version:` field).

**Current version numbers and ready-to-copy build commands (apk/appbundle/ipa, both
flavors) live in [VERSIONS.md](VERSIONS.md).**

## Configuration

### AI Provider Setup

The app supports multiple AI providers for answer validation. Configure your preferred provider in the Settings screen:

- **On-Device AI**: Works offline, no API key required
- **Google Gemini**: Requires Gemini API key
- **Anthropic Claude**: Requires Anthropic API key
- **OpenAI**: Requires OpenAI API key

API keys are stored locally and securely in the app's database.

## Project Structure

```
lib/
├── data/           # Data layer (API clients, database)
├── domain/         # Business logic, models, services
├── view/           # UI layer (screens, cubits, widgets)
├── di/             # Dependency injection setup
└── util/           # Shared utilities
```

## Tech Stack

- **State Management**: flutter_bloc (BLoC/Cubit pattern)
- **Navigation**: GoRouter
- **Database**: Drift (SQLite)
- **HTTP Client**: Chopper
- **Dependency Injection**: GetIt
- **In-App Purchases**: in_app_purchase

## Development

See [CLAUDE.md](CLAUDE.md) for detailed development instructions and architecture documentation.

## License

This project is private and not published to pub.dev.