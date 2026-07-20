// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CardsApiService extends CardsApiService {
  _$CardsApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CardsApiService;

  @override
  Future<Response<dynamic>> updateCard({
    required String id,
    required UpdateCardDto body,
  }) {
    final Uri $url = Uri.parse('/api/cards/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteCard({required String id}) {
    final Uri $url = Uri.parse('/api/cards/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
