// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$OpenAIApiService extends OpenAIApiService {
  _$OpenAIApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = OpenAIApiService;

  @override
  Future<Response<dynamic>> createChatCompletion(
      {required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('/chat/completions');
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
