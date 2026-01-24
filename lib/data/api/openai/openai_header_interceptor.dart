import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';

class OpenAIHeaderInterceptor implements RequestInterceptor {
  final ValidatorConfigProvider apiKeysProvider;

  OpenAIHeaderInterceptor(this.apiKeysProvider);

  @override
  FutureOr<Request> onRequest(Request request) async {
    final apiKey = apiKeysProvider.openAiConfig;

    // Add headers for OpenAI API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    return request.copyWith(headers: headers);
  }
}