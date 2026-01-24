import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';

class ClaudeHeaderInterceptor implements RequestInterceptor {
  final ValidatorConfigProvider apiKeysProvider;
  final String apiVersion;

  ClaudeHeaderInterceptor(
    this.apiKeysProvider, {
    this.apiVersion = '2023-06-01',
  });

  @override
  FutureOr<Request> onRequest(Request request) async {
    final config = apiKeysProvider.claudeConfig as ApiKeyConfig?;

    // Add headers for Claude API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    if (config != null) {
      headers['x-api-key'] = config.apiKey;
    }
    headers['anthropic-version'] = apiVersion;

    return request.copyWith(headers: headers);
  }
}