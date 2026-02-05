import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/l10n/app_localizations.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0
      ),
      child: DropdownButtonFormField<AnswerValidatorType>(
        isExpanded: true,
        initialValue: selectedValidator,
        dropdownColor: AppColors.grayscaleWhite,
        style: AppTypography.mainText.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grayscale300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grayscale300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary500, width: 2),
          ),
          labelText: AppLocalizations.of(context)?.answerValidatorDropdownLabel,
          labelStyle: AppTypography.secondaryText.copyWith(
            color: AppColors.grayscale500,
          ),
        ),
        items: validators.map((validatorItem) {
          return DropdownMenuItem(
            value: validatorItem.type,
            enabled: _isEnabled(validatorItem),
            child: GestureDetector(
              onTap: !_isEnabled(validatorItem)
                  ? () {
                      snackBar(
                        context,
                        message: AppLocalizations.of(context)
                                ?.answerValidatorNotAvailableMessage(
                              validatorItem.type.toDisplayString(),
                            ) ??
                            '',
                      );
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    validatorItem.type.toDisplayString(),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.mainText.copyWith(
                      color: _isEnabled(validatorItem)
                          ? AppColors.textPrimary
                          : AppColors.grayscale400,
                    ),
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
