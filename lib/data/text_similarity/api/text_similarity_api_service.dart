import 'package:chopper/chopper.dart';

part 'text_similarity_api_service.chopper.dart';

@ChopperApi()
abstract class TextSimilarityApiService extends ChopperService {
  static TextSimilarityApiService create([ChopperClient? client]) => _$TextSimilarityApiService(client);

  @Get()
  Future<Response> checkSimilarity({
    @Query("text1") required String text1,
    @Query("text2") required String text2,
  });
}
