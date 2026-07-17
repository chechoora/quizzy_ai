import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';

Future<void> showOnboardingBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _OnboardingBottomSheet(),
  );
}

class _OnboardingBottomSheet extends StatelessWidget {
  const _OnboardingBottomSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.onboardingTitle,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.grayscale600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.grayscale300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingIntro,
                  style: AppTypography.mainText.copyWith(
                    color: AppColors.grayscale500,
                  ),
                ),
                const SizedBox(height: 20),
                _OnboardingItem(
                  iconAsset: 'assets/icons/settings.svg',
                  title: l10n.onboardingItemApiKeysTitle,
                  description: l10n.onboardingItemApiKeysDescription,
                ),
                const SizedBox(height: 16),
                _OnboardingItem(
                  iconAsset: 'assets/icons/quizzy_ai.svg',
                  title: l10n.onboardingItemModelTitle,
                  description: l10n.onboardingItemModelDescription,
                ),
                const SizedBox(height: 16),
                _OnboardingItem(
                  iconAsset: 'assets/icons/decks.svg',
                  title: l10n.onboardingItemGenerateTitle,
                  description: l10n.onboardingItemGenerateDescription,
                ),
                const SizedBox(height: 16),
                _OnboardingItem(
                  iconAsset: 'assets/icons/infinity.svg',
                  title: l10n.onboardingItemPremiumTitle,
                  description: l10n.onboardingItemPremiumDescription,
                ),
                if (Platform.isIOS) ...[
                  const SizedBox(height: 16),
                  _OnboardingItem(
                    iconAsset: 'assets/icons/cloud.svg',
                    title: l10n.onboardingItemBackupTitle,
                    description: l10n.onboardingItemBackupDescription,
                  ),
                ],
                const SizedBox(height: 24),
                AppButton.primary(
                  text: l10n.onboardingContinueButton,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem extends StatelessWidget {
  const _OnboardingItem({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            AppColors.primary500,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h4.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
