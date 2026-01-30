import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';

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
            enabled: _isEnabled(validatorItem),
            child: GestureDetector(
              onTap: !_isEnabled(validatorItem)
                  ? () {
                      showSnackBar(
                        context,
                        'The ${validatorItem.type.toDisplayString()} validator is not available. Please check your configuration or purchase status.',
                      );
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    validatorItem.type.toDisplayString(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: onValidatorChanged,
      ),
    );
  }

  bool _isEnabled(ValidatorItem validatorItem) {
    final config = validatorItem.validatorConfig;
    if (config == null || config is! PurchaseConfig) {
      return true;
    }
    return config.isPurchased;
  }
}
