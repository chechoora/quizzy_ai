import 'package:chopper/chopper.dart';

abstract class GeminiApiService extends ChopperService {
  static GeminiApiService create([ChopperClient? client]) {
    final service = _GeminiApiServiceImpl();
    if (client != null) {
      service.client = client;
    }
    return service;
  }

  Future<Response> generateContent({
    required Map<String, dynamic> body,
    required String model,
  });
}

class _GeminiApiServiceImpl extends GeminiApiService {
  @override
  Future<Response> generateContent({
    required Map<String, dynamic> body,
    required String model,
  }) {
    // Manually construct the URL to avoid URI parsing issues with the colon
    final path = '$model:generateContent';
    final url = Uri.parse(client.baseUrl.toString() + path);

    final request = Request(
      'POST',
      url,
      client.baseUrl,
      body: body,
    );

    return client.send(request);
  }

  @override
  Type get definitionType => GeminiApiService;
}
