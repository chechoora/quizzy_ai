import 'package:poc_ai_quiz/domain/text_similiarity/text_similarity_service.dart';

class TextSimilarityApiMapper {
  TextSimilarityResponseModel mapSimilarity(dynamic jsonResponse) {
    final num similarity = jsonResponse['similarity'] ?? 0.0;
    return TextSimilarityResponseModel(similarity.toDouble());
  }
}
