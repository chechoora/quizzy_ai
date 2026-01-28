import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';

class AnswerValidatorDropdown extends StatelessWidget {
  const AnswerValidatorDropdown({
    super.key,
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onValidatorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<AnswerValidatorType>(
        isExpanded: true,
        initialValue: selectedValidator,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Validator Type',
        ),
        items: validators.map((validatorItem) {
          return DropdownMenuItem(
            value: validatorItem.type,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  validatorItem.type.toDisplayString(),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onValidatorChanged,
      ),
    );
  }
}
