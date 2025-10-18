// GENERATED CODE - DO NOT MODIFY BY HAND

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
