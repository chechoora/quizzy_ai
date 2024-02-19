import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:isolates/isolate_runner.dart';

class IsolateConverter extends JsonConverter {
  final IsolateRunner isolateRunner;

  const IsolateConverter(this.isolateRunner);

  @override
  Future<dynamic> tryDecodeJson(String data) async {
    final decodeResponse = await isolateRunner.run(
      (data) => _tryDecodeJson(data),
      data,
    );
    final exception = decodeResponse.exception;
    if (exception != null) {
      chopperLogger.warning(exception);
    }
    return decodeResponse.data;
  }

  DecodeResponse _tryDecodeJson(String data) {
    try {
      return DecodeResponse(json.decode(data), null);
    } catch (e) {
      return DecodeResponse(data, e);
    }
  }
}

class DecodeResponse {
  final dynamic data;
  final Object? exception;

  const DecodeResponse(this.data, this.exception);
}
