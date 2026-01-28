import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class ValidatorItem {
  final AnswerValidatorType type;
  final ValidatorConfig? validatorConfig;

  const ValidatorItem({
    required this.type,
    this.validatorConfig,
  });

  ValidatorItem copyWith({
    AnswerValidatorType? type,
    ValidatorConfig? validatorConfig,
  }) {
    return ValidatorItem(
      type: type ?? this.type,
      validatorConfig: validatorConfig ?? this.validatorConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidatorItem &&
        other.type == type &&
        other.validatorConfig == validatorConfig;
  }

  @override
  int get hashCode => type.hashCode ^ validatorConfig.hashCode;
}
