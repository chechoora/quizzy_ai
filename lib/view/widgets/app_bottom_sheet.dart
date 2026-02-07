import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

enum AppBottomSheetVariant { positive, destructive, warning, neutral }

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.button,
    this.variant = AppBottomSheetVariant.positive,
    this.content,
  });

  final Widget title;
  final Widget button;
  final AppBottomSheetVariant variant;
  final Widget? content;

  const AppBottomSheet.positive({
    super.key,
    required this.title,
    required this.button,
    this.content,
  }) : variant = AppBottomSheetVariant.positive;

  const AppBottomSheet.destructive({
    super.key,
    required this.title,
    required this.button,
    this.content,
  }) : variant = AppBottomSheetVariant.destructive;

  const AppBottomSheet.warning({
    super.key,
    required this.title,
    required this.button,
    this.content,
  }) : variant = AppBottomSheetVariant.warning;

  const AppBottomSheet.neutral({
    super.key,
    required this.title,
    required this.button,
    this.content,
  }) : variant = AppBottomSheetVariant.neutral;

  @override
  Widget build(BuildContext context) {
    final colors = _BottomSheetColors.fromVariant(variant);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              title: title,
              icon: colors.icon,
              iconColor: colors.iconColor,
            ),
            if (content != null) ...[
              const SizedBox(height: 8),
              content!,
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: button,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final Widget title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.grayscaleWhite,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        title,
      ],
    );
  }
}

class _BottomSheetColors {
  const _BottomSheetColors({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  factory _BottomSheetColors.fromVariant(AppBottomSheetVariant variant) {
    return switch (variant) {
      AppBottomSheetVariant.positive => const _BottomSheetColors(
          backgroundColor: AppColors.success100,
          icon: Icons.check,
          iconColor: AppColors.success500,
        ),
      AppBottomSheetVariant.destructive => const _BottomSheetColors(
          backgroundColor: AppColors.error100,
          icon: Icons.close,
          iconColor: AppColors.error500,
        ),
      AppBottomSheetVariant.warning => const _BottomSheetColors(
          backgroundColor: AppColors.yellow100,
          icon: Icons.warning_rounded,
          iconColor: AppColors.yellow500,
        ),
      AppBottomSheetVariant.neutral => const _BottomSheetColors(
          backgroundColor: AppColors.grayscale100,
          icon: Icons.info_outline,
          iconColor: AppColors.grayscale500,
        ),
    };
  }
}