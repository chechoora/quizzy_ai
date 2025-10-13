import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/on_device_ai_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/text_similarity_answer_validator.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

class SettingsService {
  final UserRepository userRepository;
  final GeminiAnswerValidator geminiAnswerValidator;
  final OnDeviceAIAnswerValidator onDeviceAIAnswerValidator;
  final TextSimilarityAnswerValidator textSimilarityAnswerValidator;

  SettingsService({
    required this.userRepository,
    required this.geminiAnswerValidator,
    required this.onDeviceAIAnswerValidator,
    required this.textSimilarityAnswerValidator,
  });

  Future<AnswerValidatorType> getCurrentValidatorType() async {
    final user = await userRepository.fetchCurrentUser();
    return user.answerValidatorType;
  }

  Future<void> updateValidatorType(AnswerValidatorType validatorType) async {
    final user = await userRepository.fetchCurrentUser();
    await userRepository.updateAnswerValidatorType(user.id, validatorType);
  }

  Future<IAnswerValidator> getAnswerValidator() async {
    final validatorType = await getCurrentValidatorType();
    return getValidatorByType(validatorType);
  }

  IAnswerValidator getValidatorByType(AnswerValidatorType validatorType) {
    switch (validatorType) {
      case AnswerValidatorType.gemini:
        return geminiAnswerValidator;
      case AnswerValidatorType.onDeviceAI:
        return onDeviceAIAnswerValidator;
      case AnswerValidatorType.textSimilarity:
        return textSimilarityAnswerValidator;
    }
  }
}