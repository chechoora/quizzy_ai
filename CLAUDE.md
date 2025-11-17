# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter quiz application that allows users to create decks of quiz cards, take quizzes, and manage their learning progress. The app includes premium features and uses AI text similarity for quiz validation.

## Development Commands

### Core Development
- `fvm flutter run` - Run the app in development mode
- `fvm flutter build` - Build the application
- `fvm flutter test` - Run all tests
- `fvm flutter analyze` - Run static analysis/linting
- `fvm flutter pub get` - Install dependencies
- `fvm flutter pub upgrade` - Upgrade dependencies

### Code Generation
- `fvm flutter packages pub run build_runner build` - Generate code (for Chopper, Drift, JSON serialization)
- `fvm flutter packages pub run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files
- `fvm dart run pigeon --input <input_file>` - Generate platform channel code with Pigeon

### Database
- Uses Drift for local database management
- Database models are in `lib/data/db/`
- Generated files: `database.g.dart`

## Architecture

### Clean Architecture Pattern
The codebase follows clean architecture with clear separation of concerns:

```
lib/
├── data/           # Data layer (API, database)
├── domain/         # Business logic and models
├── view/           # UI layer (widgets, cubits)
├── di/             # Dependency injection
└── util/           # Shared utilities
```

### Key Architectural Components

#### Data Layer (`lib/data/`)
- **API**: AI answer validators using Chopper HTTP client
  - `lib/data/api/gemini_ai/` - Google Gemini AI integration
  - `lib/data/api/claude/` - Anthropic Claude AI integration
  - `lib/data/api/openai/` - OpenAI GPT integration
  - `lib/data/api/on_device_ai/` - On-device AI processing
- **Database**: Drift database with repositories for deck, quiz_card, and user data
- **Isolates**: API calls run in separate isolates for performance

#### Domain Layer (`lib/domain/`)
- **Models**: Core business objects (DeckItem, QuizCardItem, etc.)
- **Services**: Business logic (QuizService, TextSimilarityService)
- **Repositories**: Abstract data access interfaces
- **Premium**: Premium feature management

#### View Layer (`lib/view/`)
- **BLoC Pattern**: Uses flutter_bloc for state management
- **Routing**: GoRouter for navigation
- **Widgets**: Screen widgets with separate display components

### Dependency Injection
- Uses GetIt for service locator pattern
- Setup in `lib/di/di.dart` with three phases:
  1. Database setup
  2. API client configuration
  3. Service registration

### Key External Services
- **AI Answer Validators**: Multiple AI services for quiz answer validation
  - **Gemini AI**: Google's Gemini models for answer scoring
  - **Claude AI**: Anthropic's Claude models for answer evaluation
  - **OpenAI**: OpenAI's GPT models (gpt-4o-mini default) for answer validation
  - **On-Device AI**: Local ML model for offline answer validation
- **In-App Purchases**: Premium feature unlocking
- **Local Storage**: Drift SQLite database

### Navigation Structure
- Home screen with deck list
- Quiz card list for each deck
- Quiz execution flow
- Deck/card creation screens
- Premium settings

## Testing
- Unit tests are located in `test/`
- Uses mocktail for mocking
- Run specific tests: `flutter test test/specific_test.dart`

## State Management
- Uses BLoC pattern with flutter_bloc
- Cubits handle screen-level state
- Services handle business logic
- Repository pattern for data access

## Premium Features
- Managed through `DeckPremiumManager` and `QuizCardPremiumManager`
- Uses in-app purchases for feature unlocking
- Premium state tracked in user repository

## Logging
- Use the `Logger` class from `lib/util/logger.dart` for all logging
- Create a logger instance with a tag: `Logger.withTag('YourClassName')`
- Available log levels: `v()` (verbose), `d()` (debug), `i()` (info), `w()` (warning), `e()` (error)
- All methods support optional exception and stack trace parameters
- Uses Fimber for underlying log implementation

## AI Answer Validators

The app supports multiple AI providers for validating quiz answers:

### OpenAI (`lib/data/api/openai/`)
- Uses OpenAI's GPT models for answer validation
- Default model: `gpt-4o-mini` (cost-effective)
- Supports structured JSON output for detailed scoring
- Returns score (0-100), explanation, correct points, and missing points
- Configured in DI with API key in `lib/di/di.dart`

### Gemini AI (`lib/data/api/gemini_ai/`)
- Uses Google's Gemini models for answer validation
- Configured with API key in dependency injection

### Claude AI (`lib/data/api/claude/`)
- Uses Anthropic's Claude models for answer validation
- Configured with API key in dependency injection

### On-Device AI (`lib/data/api/on_device_ai/`)
- Local ML model for offline answer validation
- No API key required

### Validator Selection
- Users can select their preferred validator in settings
- Validators are managed through `ValidatorsManager` and `SettingsService`
- All validators implement the `IAnswerValidator` interface