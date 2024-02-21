import 'package:poc_ai_quiz/data/api/text_similarity/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similiarity_api_mapper.dart';

class TextSimilarityService {
  TextSimilarityService({
    required this.apiService,
    required this.apiMapper,
  });

  final TextSimilarityApiService apiService;
  final TextSimilarityApiMapper apiMapper;

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
