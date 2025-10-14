import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class ValidatorItem {
  final AnswerValidatorType type;
  final bool isEnabled;

  const ValidatorItem({
    required this.type,
    required this.isEnabled,
  });

  ValidatorItem copyWith({
    AnswerValidatorType? type,
    bool? isEnabled,
  }) {
    return ValidatorItem(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidatorItem &&
        other.type == type &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => type.hashCode ^ isEnabled.hashCode;
}