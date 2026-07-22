import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/view/widgets/purchase_options_row.dart';
import 'package:quizzy_design/quizzy_design.dart';

class FeaturePurchaseCard extends StatelessWidget {
  const FeaturePurchaseCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.actionTitle,
    required this.purchasedLabel,
    required this.subtitle,
    required this.isPurchased,
    required this.onPurchase,
    this.purchaseOptions,
    this.selectedPackageIdentifier,
    this.onSelectOption,
  });

  final String iconAsset;
  final String title;
  final String description;
  final String actionTitle;
  final String purchasedLabel;
  final String subtitle;
  final bool isPurchased;
  final VoidCallback onPurchase;

  /// When non-null and non-empty, renders a Monthly/Yearly picker in place of
  /// [subtitle] (used by subscription features so the user can pick a plan).
  final List<PurchaseOption>? purchaseOptions;
  final String? selectedPackageIdentifier;
  final ValueChanged<String>? onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          SvgPicture.asset(
            iconAsset,
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              AppColors.primary500,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.h3.copyWith(
              color: AppColors.grayscale600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!isPurchased &&
              purchaseOptions != null &&
              purchaseOptions!.isNotEmpty) ...[
            PurchaseOptionsRow(
              options: purchaseOptions!,
              selectedPackageIdentifier: selectedPackageIdentifier,
              onSelected: onSelectOption!,
            ),
            const SizedBox(height: 16),
          ],
          if (isPurchased)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.success100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    purchasedLabel,
                    style: AppTypography.buttonMain.copyWith(
                      color: AppColors.success600,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.grayscaleWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionTitle,
                  style: AppTypography.buttonMain.copyWith(
                    color: AppColors.grayscaleWhite,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (purchaseOptions == null || purchaseOptions!.isEmpty)
            Text(
              subtitle,
              style: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale400,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
