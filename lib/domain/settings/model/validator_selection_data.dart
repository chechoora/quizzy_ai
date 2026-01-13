import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';

class ValidatorSelectionData {
  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> availableValidators;

  ValidatorSelectionData({
    required this.selectedValidator,
    required this.availableValidators,
  });
}