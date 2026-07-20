import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Attaches the current Firebase ID token as a Bearer token on every request
/// to the quizzy-ai-pro-be backend.
class QuizzyBackendAuthInterceptor implements RequestInterceptor {
  QuizzyBackendAuthInterceptor({
    required this.authService,
    required this.logger,
  });

  final AuthService authService;
  final Logger logger;

  @override
  FutureOr<Request> onRequest(Request request) async {
    final headers = Map<String, String>.from(request.headers);
    headers['Content-Type'] = 'application/json';

    final token = await authService.getIdToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      logger.w('onRequest: no Firebase ID token available, sending request unauthenticated');
    }

    return request.copyWith(headers: headers);
  }
}
