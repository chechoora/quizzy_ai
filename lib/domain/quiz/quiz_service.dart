import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';

class QuizService {
  final SettingsService settingsService;

  QuizService(this.settingsService);

  Future<AnswerResult> isSimilarEnough({
    required String question,
    required String initialText,
    required String inputText,
  }) async {
    final validator = await settingsService.getAnswerValidator();
    return await validator.validateAnswer(
      question: question,
      correctAnswer: initialText,
      userAnswer: inputText,
    );
  }
}
