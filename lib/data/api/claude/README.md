# Claude (Anthropic) Answer Validator

This directory contains an implementation of `IAnswerValidator` using Anthropic's Claude API.

## Usage

Users can create their own Claude validator instance by providing their API key and optionally choosing a model:

```dart
// Create Claude API client
final claudeClient = ChopperClient(
  baseUrl: Uri.parse('https://api.anthropic.com/v1/'),
  services: [
    ClaudeApiService.create(),
  ],
  interceptors: [
    ClaudeHeaderInterceptor('your-api-key-here'),
  ],
  converter: const JsonConverter(),
);

// Create validator with default model (claude-3-5-haiku-20241022)
final validator = ClaudeAnswerValidator(
  claudeClient.getService<ClaudeApiService>(),
);

// Or specify a custom model
final validatorWithCustomModel = ClaudeAnswerValidator(
  claudeClient.getService<ClaudeApiService>(),
  model: 'claude-3-5-sonnet-20241022',
);
```

## Available Models

Common Claude models you can use:
- `claude-3-5-haiku-20241022` (default, fast and cost-effective)
- `claude-3-5-sonnet-20241022` (balanced performance)
- `claude-3-opus-20240229` (most capable)
- `claude-3-sonnet-20240229`
- `claude-3-haiku-20240307`

## API Key

Users need to obtain their own Anthropic API key from: https://console.anthropic.com/settings/keys

## API Version

The interceptor uses API version `2023-06-01` by default. You can specify a different version:

```dart
ClaudeHeaderInterceptor(
  'your-api-key-here',
  apiVersion: '2023-06-01',
)
```

## Integration with Settings

This validator can be registered as a custom validator type in your settings:

```dart
final settingsService = SettingsService(
  userRepository: userRepository,
  userSettingsRepository: userSettingsRepository,
  validators: {
    AnswerValidatorType.onDeviceAI: onDeviceAIAnswerValidator,
    AnswerValidatorType.gemini: geminiAnswerValidator,
    AnswerValidatorType.custom: claudeAnswerValidator, // User's custom Claude validator
  }
);
```

## Response Format

This validator uses Claude's **tool use** feature for structured JSON output. Instead of relying on prompt engineering alone, it defines a tool called `record_quiz_score` with a JSON schema that matches the `QuizScore` structure.

When you provide `toolChoice: {'type': 'tool', 'name': 'record_quiz_score'}`, Claude is forced to use that specific tool, which ensures the response follows the exact schema with proper types and required fields.

The tool schema defines:
- `score`: integer between 0 and 100
- `explanation`: string with brief explanation
- `correctPoints`: array of strings
- `missingPoints`: array of strings

This approach provides similar reliability to OpenAI's structured outputs, as Claude validates the response against the tool's input schema.