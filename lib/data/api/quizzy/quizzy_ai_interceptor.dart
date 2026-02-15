import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/util/env_hide.dart';

class QuizzyAIInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
    headers['x-app-token'] = QuizzyAI.apiKey;

    return request.copyWith(headers: headers);
  }
}
