import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/data/text_similarity/api/util.dart';

class TextSimilarityHeaderInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    final headers = request.headers;
    headers['X-RapidAPI-Key'] = apiKey;
    Request newRequest = request.copyWith(
      headers: headers,
    );
    return newRequest;
  }
}