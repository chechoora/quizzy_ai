import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';

class GeminiHeaderInterceptor implements RequestInterceptor {
  final ValidatorConfigProvider apiKeysProvider;

  GeminiHeaderInterceptor(this.apiKeysProvider);

  @override
  FutureOr<Request> onRequest(Request request) async {
    final apiKey = apiKeysProvider.geminiConfig;

    // Add Content-Type header
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';

    // Add API key as query parameter if it exists
    final uri = request.uri;
    final newUri = apiKey != null
        ? uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              'key': apiKey,
            },
          )
        : uri;

    return request.copyWith(uri: newUri, headers: headers);
  }
}