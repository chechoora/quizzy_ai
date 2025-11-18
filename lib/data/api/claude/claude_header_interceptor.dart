import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';

class ClaudeHeaderInterceptor implements RequestInterceptor {
  final ApiKeysProvider apiKeysProvider;
  final String apiVersion;

  ClaudeHeaderInterceptor(
    this.apiKeysProvider, {
    this.apiVersion = '2023-06-01',
  });

  @override
  FutureOr<Request> onRequest(Request request) async {
    final apiKey = apiKeysProvider.claudeApiKey;

    // Add headers for Claude API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    if (apiKey != null) {
      headers['x-api-key'] = apiKey;
    }
    headers['anthropic-version'] = apiVersion;

    return request.copyWith(headers: headers);
  }
}