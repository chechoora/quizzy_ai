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
            enabled: validatorItem.isEnabled,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    validatorItem.type.toDisplayString(),
                    style: TextStyle(
                      color: validatorItem.isEnabled
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                if (!validatorItem.isEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: onValidatorChanged,
      ),
    );
  }
}
