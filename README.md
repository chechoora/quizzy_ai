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

4. Run the app:
   ```bash
   fvm flutter run
   ```

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