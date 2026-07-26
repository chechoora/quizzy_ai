// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AnalyticsApiService extends AnalyticsApiService {
  _$AnalyticsApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AnalyticsApiService;

  @override
  Future<Response<dynamic>> trackEvents({required TrackEventsDto body}) {
    final Uri $url = Uri.parse('/api/analytics/events');
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
