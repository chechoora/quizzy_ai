import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Header names that carry credentials and must never appear in logs verbatim.
const _sensitiveHeaders = {'authorization', 'x-api-key'};

/// Query parameter names that carry credentials (Gemini passes its API key as
/// `?key=...`) and must never appear in logs verbatim.
const _sensitiveQueryParams = {'key'};

const _redacted = '***REDACTED***';

/// Logs method/path/headers/body of every outgoing request and the
/// status/headers/body of every response for a [ChopperClient].
///
/// Credential-bearing headers and query parameters are redacted before
/// logging; everything else (including request/response bodies, which may
/// contain answer content) is logged as-is.
class ApiLoggingInterceptor implements RequestInterceptor, ResponseInterceptor {
  ApiLoggingInterceptor(this.logger);

  final Logger logger;

  @override
  FutureOr<Request> onRequest(Request request) {
    final buffer = StringBuffer(
      'onRequest: ${request.method} ${_redactUri(request.uri)}',
    );
    _writeHeaders(buffer, request.headers);
    _writeBody(buffer, request.body?.toString());

    logger.d(buffer.toString());
    return request;
  }

  @override
  FutureOr<Response> onResponse(Response response) {
    final base = response.base;
    final statusCode = response.statusCode;
    final buffer = StringBuffer(
      'onResponse: ${base.request?.method} '
      '${base.request != null ? _redactUri(base.request!.url) : ''} -> $statusCode',
    );
    _writeHeaders(buffer, response.headers);

    final message = buffer.toString();
    if (statusCode >= 500) {
      logger.e(message);
    } else if (statusCode >= 400) {
      logger.w(message);
    } else {
      logger.i(message);
    }

    return response;
  }

  void _writeHeaders(StringBuffer buffer, Map<String, String> headers) {
    headers.forEach((key, value) {
      final isSensitive = _sensitiveHeaders.contains(key.toLowerCase());
      buffer.write('\n  $key: ${isSensitive ? _redacted : value}');
    });
  }

  void _writeBody(StringBuffer buffer, String? body) {
    if (body != null && body.isNotEmpty) {
      buffer.write('\n  body: $body');
    }
  }

  Uri _redactUri(Uri uri) {
    if (uri.queryParameters.keys
        .every((key) => !_sensitiveQueryParams.contains(key.toLowerCase()))) {
      return uri;
    }

    final redactedParams = {
      for (final entry in uri.queryParameters.entries)
        entry.key: _sensitiveQueryParams.contains(entry.key.toLowerCase())
            ? _redacted
            : entry.value,
    };
    return uri.replace(queryParameters: redactedParams);
  }
}
