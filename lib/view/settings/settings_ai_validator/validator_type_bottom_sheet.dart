import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_type_ui_data.dart';

Future<AnswerValidatorType?> showValidatorTypeBottomSheet(
  BuildContext context, {
  required AnswerValidatorType selectedValidator,
  required List<ValidatorItem> validators,
}) {
  return showModalBottomSheet<AnswerValidatorType>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => _ValidatorTypeBottomSheet(
      selectedValidator: selectedValidator,
      validators: validators,
    ),
  );
}

class _ValidatorTypeBottomSheet extends StatelessWidget {
  const _ValidatorTypeBottomSheet({
    required this.selectedValidator,
    required this.validators,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetHeader(
              title: l10n.answerValidatorDropdownLabel,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                itemCount: validators.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final item = validators[index];
                  final isSelected = item.type == selectedValidator;
                  final isDisabled = _isDisabled(item);
                  return _ValidatorOptionCard(
                    validatorItem: item,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: isDisabled
                        ? null
                        : () => Navigator.of(context).pop(item.type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDisabled(ValidatorItem item) {
    final config = item.validatorConfig;
    if (config is PurchaseConfig) {
      return !config.isPurchased;
    }
    return false;
  }
}

class _BottomSheetHeader extends StatelessWidget {
  const _BottomSheetHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grayscale200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              size: 24,
              color: AppColors.grayscale600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidatorOptionCard extends StatelessWidget {
  const _ValidatorOptionCard({
    required this.validatorItem,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  final ValidatorItem validatorItem;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final uiData = getValidatorUIData(validatorItem.type);
    final textColor =
        isDisabled ? AppColors.grayscale400 : AppColors.grayscale600;
    final descColor =
        isDisabled ? AppColors.grayscale400 : AppColors.grayscale500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.grayscaleWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              uiData.iconAsset,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  validatorItem.type.toDisplayString(),
                  style: AppTypography.h4.copyWith(color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  uiData.getDescription(l10n),
                  style: AppTypography.smallText.copyWith(color: descColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _RadioIndicator(
            isSelected: isSelected,
            isDisabled: isDisabled,
          ),
        ],
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({
    required this.isSelected,
    required this.isDisabled,
  });

  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary500,
          border: Border.all(color: AppColors.primary500),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.grayscaleWhite,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    if (isDisabled) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          border: Border.all(color: AppColors.grayscale300),
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayscale500),
        shape: BoxShape.circle,
      ),
    );
  }
}