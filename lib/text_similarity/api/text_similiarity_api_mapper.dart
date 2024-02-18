import 'package:poc_ai_quiz/text_similarity/text_similarity_service.dart';

class TextSimilarityApiMapper {
  TextSimilarityResponseModel mapSimilarity(dynamic jsonResponse) {
    final double similarity = jsonResponse['similarity'] ?? 0.0;
    return TextSimilarityResponseModel(similarity);
  }
}
