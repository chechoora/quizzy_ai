// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_decks_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PublicDecksApiService extends PublicDecksApiService {
  _$PublicDecksApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PublicDecksApiService;

  @override
  Future<Response<dynamic>> listCategories() {
    final Uri $url = Uri.parse('/api/public/categories');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> listDecks({
    String? category,
    String? tag,
    String? q,
    String? cursor,
    int? limit,
  }) {
    final Uri $url = Uri.parse('/api/public/decks');
    final Map<String, dynamic> $params = <String, dynamic>{
      'category': category,
      'tag': tag,
      'q': q,
      'cursor': cursor,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getDeck({required String id}) {
    final Uri $url = Uri.parse('/api/public/decks/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> copyDeck({required String id}) {
    final Uri $url = Uri.parse('/api/public/decks/${id}/copy');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
