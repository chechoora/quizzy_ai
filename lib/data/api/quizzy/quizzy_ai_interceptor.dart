import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/util/env_hide.dart';

class QuizzyAIInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    // Add any necessary headers for Quizzy AI API
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';
   // headers['Api-Key'] = QuizzyAI.apiKey;

    return request.copyWith(headers: headers);
  }
}
