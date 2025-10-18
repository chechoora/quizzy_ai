import 'dart:async';
import 'package:chopper/chopper.dart';

class ClaudeHeaderInterceptor implements RequestInterceptor {
  final String apiKey;
  final String apiVersion;

  ClaudeHeaderInterceptor(
    this.apiKey, {
    this.apiVersion = '2023-06-01',
  });

  @override
  FutureOr<Request> onRequest(Request request) async {
    // Add headers for Claude API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    headers['x-api-key'] = apiKey;
    headers['anthropic-version'] = apiVersion;

    return request.copyWith(headers: headers);
  }
}