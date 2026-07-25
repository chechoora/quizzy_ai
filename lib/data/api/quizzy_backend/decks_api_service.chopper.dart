// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decks_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$DecksApiService extends DecksApiService {
  _$DecksApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = DecksApiService;

  @override
  Future<Response<dynamic>> generateDeck({required GenerateDeckDto body}) {
    final Uri $url = Uri.parse('/api/decks/generate');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> listDecks() {
    final Uri $url = Uri.parse('/api/decks');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createDeck({required CreateDeckDto body}) {
    final Uri $url = Uri.parse('/api/decks');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createDecks({required List<CreateDeckDto> body}) {
    final Uri $url = Uri.parse('/api/decks/batch');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getDeck({required String id}) {
    final Uri $url = Uri.parse('/api/decks/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateDeck({
    required String id,
    required UpdateDeckDto body,
  }) {
    final Uri $url = Uri.parse('/api/decks/${id}');
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
  Future<Response<dynamic>> deleteDeck({required String id}) {
    final Uri $url = Uri.parse('/api/decks/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> listCards({required String id}) {
    final Uri $url = Uri.parse('/api/decks/${id}/cards');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addCards({
    required String id,
    required List<CardDto> body,
  }) {
    final Uri $url = Uri.parse('/api/decks/${id}/cards/batch');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateCards({
    required String id,
    required List<UpdateCardBatchItemDto> body,
  }) {
    final Uri $url = Uri.parse('/api/decks/${id}/cards/batch');
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
  Future<Response<dynamic>> deleteCards({
    required String id,
    required BatchDeleteCardsDto body,
  }) {
    final Uri $url = Uri.parse('/api/decks/${id}/cards/batch');
    final $body = body;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
