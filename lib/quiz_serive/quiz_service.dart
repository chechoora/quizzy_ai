import 'package:poc_ai_quiz/text_similarity/text_similarity_service.dart';

class QuizService {
  final TextSimilarityService textSimilarityService;

  QuizService(this.textSimilarityService);

  Future<double> isSimilarEnough({
    required String initialText,
    required String inputText,
  }) async {
    final howSimilar = await textSimilarityService.checkSimilarity(
      initialText: initialText,
      inputText: inputText,
    );
    return howSimilar.similarity;
  }
}
