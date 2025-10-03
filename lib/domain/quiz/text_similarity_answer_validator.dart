import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similarity_service.dart';

class TextSimilarityAnswerValidator implements IAnswerValidator {
  final TextSimilarityService textSimilarityService;

  TextSimilarityAnswerValidator(this.textSimilarityService);

  @override
  Future<double> validateAnswer({
    required String correctAnswer,
    required String userAnswer,
  }) async {
    final result = await textSimilarityService.checkSimilarity(
      initialText: correctAnswer,
      inputText: userAnswer,
    );
    return result.similarity;
  }
}