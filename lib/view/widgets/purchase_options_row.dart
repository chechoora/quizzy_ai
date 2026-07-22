import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';

class PurchaseOptionsRow extends StatelessWidget {
  const PurchaseOptionsRow({
    super.key,
    required this.options,
    required this.selectedPackageIdentifier,
    required this.onSelected,
  });

  final List<PurchaseOption> options;
  final String? selectedPackageIdentifier;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Row(
      children: [
        for (final option in options) ...[
          if (option != options.first) const SizedBox(width: 12),
          Expanded(
            child: PurchaseOptionCard(
              label: switch (option.period) {
                SubscriptionPeriod.monthly => l10n.inAppFeaturesMonthlyLabel,
                SubscriptionPeriod.yearly => l10n.inAppFeaturesYearlyLabel,
                SubscriptionPeriod.other => option.priceString,
              },
              priceString: option.priceString,
              isSelected: option.packageIdentifier == selectedPackageIdentifier,
              isBestValue: option.period == SubscriptionPeriod.yearly,
              onTap: () => onSelected(option.packageIdentifier),
            ),
          ),
        ],
      ],
    );
  }
}

class PurchaseOptionCard extends StatelessWidget {
  const PurchaseOptionCard({
    super.key,
    required this.label,
    required this.priceString,
    required this.isSelected,
    required this.isBestValue,
    required this.onTap,
  });

  final String label;
  final String priceString;
  final bool isSelected;
  final bool isBestValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.grayscale200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.mainText.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              priceString,
              style: AppTypography.h3.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
