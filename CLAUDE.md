# CLAUDE.md

Development guidance for Claude Code when working with this repository.

## Commands

```bash
# Run the app
fvm flutter run

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

final _logger = Logger.withTag('ClassName');
_logger.d('Debug message');
_logger.i('Info message');
_logger.w('Warning message');
_logger.e('Error message', exception, stackTrace);
```

## Testing

- Tests in `test/` directory
- Mocking with mocktail
- Run specific test: `fvm flutter test test/specific_test.dart`

## Premium Features

Managed by:
- `DeckPremiumManager` - Deck-related premium features
- `QuizCardPremiumManager` - Quiz card premium features

Premium state tracked in `UserRepository`.