import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class ValidatorItem {
  final AnswerValidatorType type;
  final bool isEnabled;
  final ValidatorConfig? validatorConfig;

  const ValidatorItem({
    required this.type,
    required this.isEnabled,
    this.validatorConfig,
  });

  ValidatorItem copyWith({
    AnswerValidatorType? type,
    bool? isEnabled,
    ValidatorConfig? validatorConfig,
  }) {
    return ValidatorItem(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      validatorConfig: validatorConfig ?? this.validatorConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidatorItem &&
        other.type == type &&
        other.isEnabled == isEnabled &&
        other.validatorConfig == validatorConfig;
  }

  @override
  int get hashCode =>
      type.hashCode ^ isEnabled.hashCode ^ validatorConfig.hashCode;
}
