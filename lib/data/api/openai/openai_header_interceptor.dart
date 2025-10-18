import 'dart:async';
import 'package:chopper/chopper.dart';

class OpenAIHeaderInterceptor implements RequestInterceptor {
  final String apiKey;

  OpenAIHeaderInterceptor(this.apiKey);

  @override
  FutureOr<Request> onRequest(Request request) async {
    // Add headers for OpenAI API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    headers['Authorization'] = 'Bearer $apiKey';

    return request.copyWith(headers: headers);
  }
}