import 'package:poc_ai_quiz/data/text_similarity/api/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/data/text_similarity/api/text_similiarity_api_mapper.dart';

class TextSimilarityService {
  final TextSimilarityApiService apiService;
  final TextSimilarityApiMapper apiMapper;

  TextSimilarityService({
    required this.apiService,
    required this.apiMapper,
  });

  Future<TextSimilarityResponseModel> checkSimilarity({
    required String initialText,
    required String inputText,
  }) async {
    final response = await apiService.checkSimilarity(text1: initialText, text2: inputText);
    if (response.isSuccessful) {
      final body = response.body;
      return apiMapper.mapSimilarity(body);
    }
    // TODO change to specific exception.
    throw Exception('response is not successful');
  }
}

class TextSimilarityResponseModel {
  final double similarity;

  TextSimilarityResponseModel(this.similarity);
}
