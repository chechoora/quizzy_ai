import 'dart:async';
import 'package:chopper/chopper.dart';

class GeminiHeaderInterceptor implements RequestInterceptor {
  final String apiKey;

  GeminiHeaderInterceptor(this.apiKey);

  @override
  FutureOr<Request> onRequest(Request request) async {
    // Add Content-Type header
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';

    // Add API key as query parameter
    final uri = request.uri;
    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'key': apiKey,
      },
    );

    return request.copyWith(uri: newUri, headers: headers);
  }
}