/// Helpers shared by the Ollama answer validator and deck generator.
///
/// Ollama is reached over plain `http` rather than a Chopper client, so the
/// URL normalization and response unwrapping live here instead of in an
/// interceptor / converter.
library;

/// Normalizes a user-entered Ollama base URL: adds a scheme when missing and
/// drops a trailing slash.
String buildOllamaUrl(String baseUrl) {
  var normalizedUrl = baseUrl.trim();

  // Add http:// scheme if missing
  if (!normalizedUrl.startsWith('http://') &&
      !normalizedUrl.startsWith('https://')) {
    normalizedUrl = 'http://$normalizedUrl';
  }

  // Remove trailing slash if present
  if (normalizedUrl.endsWith('/')) {
    normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
  }

  return normalizedUrl;
}

/// Pulls the assistant message content out of an Ollama `/api/chat` response,
/// accepting both the OpenAI-compatible `choices` shape and Ollama's native
/// `message` shape. Returns null when neither carries content, leaving the
/// caller to throw its own exception type.
String? extractOllamaContent(Map<String, dynamic> responseJson) {
  final choices = responseJson['choices'] as List<dynamic>?;
  if (choices != null && choices.isNotEmpty) {
    // OpenAI-compatible format
    final choice = choices.first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>?;
    return message?['content'] as String?;
  }

  // Ollama native format
  final message = responseJson['message'] as Map<String, dynamic>?;
  return message?['content'] as String?;
}

/// Strips markdown code fences that models often wrap JSON in, leaving a bare
/// JSON string ready for `jsonDecode`.
String stripJsonFences(String content) {
  String jsonString = content.trim();

  if (jsonString.startsWith('```json')) {
    jsonString = jsonString.substring(7);
  } else if (jsonString.startsWith('```')) {
    jsonString = jsonString.substring(3);
  }
  if (jsonString.endsWith('```')) {
    jsonString = jsonString.substring(0, jsonString.length - 3);
  }

  return jsonString.trim();
}
