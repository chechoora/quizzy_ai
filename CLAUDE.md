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
- **API**: Text similarity service using Chopper HTTP client
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
- **Text Similarity API**: RapidAPI Twinword service for quiz answer validation
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