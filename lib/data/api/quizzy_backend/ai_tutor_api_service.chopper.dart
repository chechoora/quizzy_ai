// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tutor_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AiTutorApiService extends AiTutorApiService {
  _$AiTutorApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AiTutorApiService;

  @override
  Future<Response<dynamic>> checkAnswer({required CheckAnswerDto body}) {
    final Uri $url = Uri.parse('/api/ai-tutor/check-answer');
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
