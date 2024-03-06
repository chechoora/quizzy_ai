import 'package:poc_ai_quiz/domain/text_similiarity/text_similarity_service.dart';

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
