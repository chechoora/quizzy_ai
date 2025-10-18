# OpenAI Answer Validator

This directory contains an implementation of `IAnswerValidator` using OpenAI's API.

## Usage

Users can create their own OpenAI validator instance by providing their API key and optionally choosing a model:

```dart
// Create OpenAI API client
final openAIClient = ChopperClient(
  baseUrl: Uri.parse('https://api.openai.com/v1/'),
  services: [
    OpenAIApiService.create(),
  ],
  interceptors: [
    OpenAIHeaderInterceptor('your-api-key-here'),
  ],
  converter: const JsonConverter(),
);

// Create validator with default model (gpt-4o-mini)
final validator = OpenAIAnswerValidator(
  openAIClient.getService<OpenAIApiService>(),
);

// Or specify a custom model
final validatorWithCustomModel = OpenAIAnswerValidator(
  openAIClient.getService<OpenAIApiService>(),
  model: 'gpt-4',
);
```

## Available Models

Common OpenAI models you can use:
- `gpt-4o-mini` (default, cost-effective)
- `gpt-4o`
- `gpt-4-turbo`
- `gpt-4`
- `gpt-3.5-turbo`

## API Key

Users need to obtain their own OpenAI API key from: https://platform.openai.com/api-keys

## Integration with Settings

This validator can be registered as a custom validator type in your settings:

```dart
final settingsService = SettingsService(
  userRepository: userRepository,
  userSettingsRepository: userSettingsRepository,
  validators: {
    AnswerValidatorType.onDeviceAI: onDeviceAIAnswerValidator,
    AnswerValidatorType.gemini: geminiAnswerValidator,
    AnswerValidatorType.custom: openAIAnswerValidator, // User's custom OpenAI validator
  }
);
```