# OnDevice AI Implementation with Foundation Models

This implementation uses Apple's Foundation Models framework to provide on-device AI capabilities for validating quiz answers.

## Setup Instructions

### 1. Add Foundation Models Framework

In your iOS project:

1. Open your iOS project in Xcode (`ios/Runner.xcodeproj`)
2. Select your app target
3. Go to "General" > "Frameworks, Libraries, and Embedded Content"
4. Click the "+" button and add `FoundationModels.framework`

### 2. Update Info.plist

Add the following to your `ios/Runner/Info.plist` to declare that your app uses Apple Intelligence features:

```xml
<key>NSAppleIntelligenceUsageDescription</key>
<string>This app uses on-device AI to evaluate quiz answers and provide educational feedback.</string>
```

### 3. System Requirements

Foundation Models requires:
- iOS 18.2+ or iPadOS 18.2+
- macOS 15.2+ (for macOS apps)
- Device with Apple Intelligence support
- Apple Intelligence enabled in system settings

### 4. Testing

The implementation includes proper availability checking:

- `isOnDeviceAIAvailable()` will return `true` when Foundation Models is available
- `validateAnswer()` will return appropriate errors if the model is unavailable

### 5. Usage

The implementation automatically:
- Checks model availability before processing requests
- Uses structured prompting to ensure consistent scoring (0.0 to 1.0)
- Provides detailed reasoning for each score
- Handles errors gracefully with appropriate error codes

## Features

- **Semantic Understanding**: Uses Apple's on-device LLM to understand context and meaning
- **Structured Scoring**: Returns scores from 0.0 to 1.0 with detailed reasoning
- **Privacy-First**: All processing happens on-device, no data sent to servers
- **Error Handling**: Proper error handling for unavailable models or processing failures
- **Performance**: Optimized for quick response times

## Architecture

```
Flutter App
    ↓
OnDeviceAiApi (Pigeon-generated interface)
    ↓
OnDeviceAiApiImplementation (Swift implementation)
    ↓
Foundation Models Framework
    ↓
On-device Apple Intelligence Model
```

The implementation uses guided generation to ensure consistent, structured responses that match the expected `CardAnswerResult` format.