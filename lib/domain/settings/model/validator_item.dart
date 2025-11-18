import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';

class ValidatorItem {
  final AnswerValidatorType type;
  final bool isEnabled;
  final String? apiKey;

  const ValidatorItem({
    required this.type,
    required this.isEnabled,
    this.apiKey,
  });

  ValidatorItem copyWith({
    AnswerValidatorType? type,
    bool? isEnabled,
    String? apiKey,
  }) {
    return ValidatorItem(
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidatorItem &&
        other.type == type &&
        other.isEnabled == isEnabled &&
        other.apiKey == apiKey;
  }

  @override
  int get hashCode => type.hashCode ^ isEnabled.hashCode ^ apiKey.hashCode;
}