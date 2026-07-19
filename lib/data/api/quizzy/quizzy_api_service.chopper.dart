// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quizzy_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$QuizzyApiService extends QuizzyApiService {
  _$QuizzyApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = QuizzyApiService;

  @override
  Future<Response<dynamic>> validateAnswer({
    required String userId,
    required CheckAnswerRequest body,
  }) {
    final Uri $url = Uri.parse('/api/ai-tutor/check-answer');
    final Map<String, dynamic> $params = <String, dynamic>{'userId': userId};
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> generateDeck({
    required String userId,
    required GenerateDeckRequest body,
  }) {
    final Uri $url = Uri.parse('/api/decks/generate');
    final Map<String, dynamic> $params = <String, dynamic>{'userId': userId};
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQuota({required String appUserId}) {
    final Uri $url = Uri.parse('/api/users/${appUserId}/balance');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
