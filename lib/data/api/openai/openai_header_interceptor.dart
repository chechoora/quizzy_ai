import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';

class OpenAIHeaderInterceptor implements RequestInterceptor {
  final ValidatorConfigProvider apiKeysProvider;

  OpenAIHeaderInterceptor(this.apiKeysProvider);

  @override
  FutureOr<Request> onRequest(Request request) async {
    final config = apiKeysProvider.openAiConfig as ApiKeyConfig?;

    // Add headers for OpenAI API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    if (config != null) {
      headers['Authorization'] = 'Bearer ${config.apiKey}';
    }

    return request.copyWith(headers: headers);
  }
}