import 'dart:async';

import 'package:chopper/chopper.dart';

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

const apiKey = '15483a67e7mshdfc12f77cdecd50p146efcjsnc42dcc6d2d8f';
