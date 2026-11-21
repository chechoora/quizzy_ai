// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'claude_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ClaudeApiService extends ClaudeApiService {
  _$ClaudeApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ClaudeApiService;

  @override
  Future<Response<dynamic>> createMessage(
      {required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('/messages');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ClaudeModelsApiService extends ClaudeModelsApiService {
  _$ClaudeModelsApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ClaudeModelsApiService;

  @override
  Future<Response<dynamic>> listModels({
    required String apiKey,
    int limit = 1000,
  }) {
    final Uri $url = Uri.parse('/models');
    final Map<String, dynamic> $params = <String, dynamic>{'limit': limit};
    final Map<String, String> $headers = {
      'x-api-key': apiKey,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
