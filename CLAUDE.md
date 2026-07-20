# CLAUDE.md

Development guidance for Claude Code when working with this repository.

## Commands

```bash
# Run the app (must pass a flavor + matching entry point — see Flavors)
fvm flutter run --flavor quizzy    -t lib/main_quizzy.dart
fvm flutter run --flavor quizzypro -t lib/main_quizzypro.dart

# Build Android APK (debug)
fvm flutter build apk --flavor quizzy    -t lib/main_quizzy.dart --debug
fvm flutter build apk --flavor quizzypro -t lib/main_quizzypro.dart --debug

# Build iOS (debug, no code signing)
fvm flutter build ios --flavor quizzy    -t lib/main_quizzy.dart --debug --no-codesign
fvm flutter build ios --flavor quizzypro -t lib/main_quizzypro.dart --debug --no-codesign

# Build Android App Bundle (release, for Play Store)
fvm flutter build appbundle --flavor quizzy    -t lib/main_quizzy.dart --release
fvm flutter build appbundle --flavor quizzypro -t lib/main_quizzypro.dart --release

# Run tests
fvm flutter test

# Static analysis
fvm flutter analyze

# Install dependencies
fvm flutter pub get

# Code generation (Chopper, Drift, JSON serialization)
fvm flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate Pigeon platform channel code
fvm dart run pigeon --input <input_file>
```

## Flavors

Two build flavors share one codebase (infrastructure in `lib/config/app_config.dart`):

| Flavor      | App name      | Android applicationId      | iOS bundle id              | Entry point                |
|-------------|---------------|----------------------------|----------------------------|----------------------------|
| `quizzy`    | Quizzy AI     | `com.chechoora.quizzy`     | `com.chechoora.quizzy`     | `lib/main_quizzy.dart`     |
| `quizzypro` | Quizzy AI Pro | `com.chechoora.quizzy.pro` | `com.chechoora.quizzy.pro` | `lib/main_quizzypro.dart`  |

- Each entry point builds an `AppConfig` and calls `mainCommon(config)` in `main.dart`.
  `AppConfig` is registered in GetIt (`getIt<AppConfig>()`). Its `enableByok` /
  `requireAuth` flags are declared for later and NOT consumed anywhere yet.
- Always pass `--flavor <name>` together with `-t lib/main_<name>.dart`.
- Firebase: `quizzy` uses `android/app/google-services.json` /
  `ios/Runner/GoogleService-Info.plist` (unchanged defaults). `quizzypro` needs a
  separate Firebase app (same "Quizzy AI" project) — drop
  `android/app/src/quizzypro/google-services.json` and
  `ios/config/quizzypro/GoogleService-Info.plist` (see the READMEs there). On iOS the
  "Copy flavor GoogleService-Info.plist" build phase overrides the bundled plist with
  the flavor's copy for any non-`quizzy` flavor.
- After changing iOS build configurations, run `cd ios && pod install`.
- Release Android builds are signed using `android/release_key.properties`
  (keystore path + credentials, gitignored), referenced by
  `android/app/build.gradle.kts`. It must exist before running `appbundle --release`.

## Release Versioning

`quizzy` and `quizzypro` are versioned **independently**. There is no per-flavor
version stored in `pubspec.yaml` — each release build must pass
`--build-name=<version>` and `--build-number=<build>` explicitly on the CLI.
Without these flags, both platforms fall back to `pubspec.yaml`'s `version:`
field (shared by both flavors — only meant as a dev-time default for plain
`flutter run`).

**Current version numbers and ready-to-copy build commands live in
[VERSIONS.md](VERSIONS.md)** — bump the numbers there before every release.

How the flags are wired (fixed to actually work — do not hardcode these again):
- Android: `android/app/build.gradle.kts` → `versionCode = flutter.versionCode`,
  `versionName = flutter.versionName` (both read from the CLI flags / pubspec).
- iOS: `ios/Runner/Info.plist` (quizzy) and `ios/Runner/Info-quizzypro.plist`
  (quizzypro) → `CFBundleVersion = $(FLUTTER_BUILD_NUMBER)`,
  `CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)`. The 6 Runner-target build
  configs in `ios/Runner.xcodeproj/project.pbxproj` mirror this via
  `CURRENT_PROJECT_VERSION = $(FLUTTER_BUILD_NUMBER)` /
  `MARKETING_VERSION = $(FLUTTER_BUILD_NAME)`.

## Architecture

Clean architecture with BLoC pattern:

```
lib/
├── data/                    # Data layer
│   ├── api/                 # API clients (Chopper)
│   │   ├── gemini_ai/       # Google Gemini integration
│   │   ├── claude/          # Anthropic Claude integration
│   │   ├── openai/          # OpenAI GPT integration
│   │   └── on_device_ai/    # Local ML model
│   ├── db/                  # Drift database
│   │   ├── deck/            # Deck repository
│   │   ├── quiz_card/       # Quiz card repository
│   │   ├── user/            # User repository
│   │   └── user_settings/   # Settings repository
│   └── premium/             # Premium feature data
├── domain/                  # Business logic
│   ├── deck/                # Deck model, repository, mapper
│   ├── quiz_card/           # Quiz card model, repository, premium
│   ├── quiz/                # Quiz engine, service, validators
│   ├── settings/            # Validator management, settings service
│   ├── user/                # User model, repository
│   └── user_settings/       # User settings, API keys
├── view/                    # UI layer
│   ├── home_widget/         # Home screen (deck list)
│   ├── quiz_card_list/      # Quiz cards for a deck
│   ├── quiz_exe/            # Quiz execution flow
│   ├── quiz_widget/         # Quiz display
│   ├── create_deck/         # Deck creation
│   ├── create_card/         # Card creation/editing
│   └── settings/            # Settings screens
├── di/                      # GetIt dependency injection
└── util/                    # Utilities (logger, theme, alerts)
```

## Key Patterns

### State Management
- Cubits for screen-level state (`*_cubit.dart`)
- Services for business logic (`*_service.dart`)
- Repository pattern for data access

### Widgets
- Use `flutter_hooks` for stateful widgets - extend `HookWidget` instead of `StatefulWidget`
- Use hooks like `useState`, `useFocusNode`, `useTextEditingController`, etc.
- Look up reusable widgets in `lib/view/widgets/` before creating new ones

### Theme & Styling
- Colors: `lib/util/theme/app_colors.dart` - use `AppColors.*`
- Typography: `lib/util/theme/app_typography.dart` - use `AppTypography.*`

### Answer Validators
All validators implement `IAnswerValidator` interface (`lib/domain/quiz/i_answer_validator.dart`):
- `GeminiAnswerValidator` - Google Gemini API
- `ClaudeAnswerValidator` - Anthropic Claude API
- `OpenAIAnswerValidator` - OpenAI GPT API (default: gpt-4o-mini)
- `OnDeviceAIAnswerValidator` - Local ML model

Validator selection managed by `ValidatorsManager` and `SettingsService`.

### Dependency Injection
Setup in `lib/di/di.dart`:
1. Database initialization
2. Repository registration
3. API keys provider setup
4. API client configuration
5. Service registration

### Navigation
GoRouter with named routes:
- `/` - Home (deck list)
- `/quizCardList` - Cards in a deck
- `/quizExe` - Quiz execution
- `/createDeck` - Create/edit deck
- `/createCard` - Create/edit card
- `/premiumSettings` - Premium settings

## Database

Drift (SQLite) with tables in `lib/data/db/`:
- `deck_table.dart` - Deck storage
- `quiz_card_table.dart` - Quiz card storage (via `database.dart`)
- `user_table.dart` - User data
- `user_settings_table.dart` - Settings and API keys

Generated file: `database.g.dart`

## Logging

```dart
import 'package:poc_ai_quiz/util/logger.dart';

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', ex: exception, stacktrace: stackTrace);
```

**Inject the `Logger` — never construct it inside the class.** Take a `final Logger logger;`
constructor parameter and pass `Logger.withTag('ClassName')` from the composition root
(e.g. `lib/di/di.dart`). This keeps the logger mockable in tests. Do NOT create it inline
with `final _logger = Logger.withTag('ClassName');`.

**Every new class you create must be covered with logs.** Give it an injected `logger` field and log:
- `d` at the start of each public method with its key arguments, and at significant branch points / decisions (e.g. why an early return happened).
- `i` for successful outcomes of meaningful operations (uploads, restores, saves).
- `w` for expected-but-notable conditions (a skipped operation, an unavailable resource).
- `e` (with `ex:` and `stacktrace:`) in every `catch` block; rethrow if the caller needs to handle it.

## Testing

- Tests in `test/` directory
- Mocking with mocktail
- Run specific test: `fvm flutter test test/specific_test.dart`

## Premium Features

Managed by:
- `DeckPremiumManager` - Deck-related premium features
- `QuizCardPremiumManager` - Quiz card premium features

Premium state tracked in `UserRepository`.