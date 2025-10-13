import 'package:poc_ai_quiz/domain/settings/settings_service.dart';

class QuizService {
  final SettingsService settingsService;

  QuizService(this.settingsService);

  Future<double> isSimilarEnough({
    required String initialText,
    required String inputText,
  }) async {
    final validator = await settingsService.getAnswerValidator();
    return await validator.validateAnswer(
      correctAnswer: initialText,
      userAnswer: inputText,
    );
  }
}
