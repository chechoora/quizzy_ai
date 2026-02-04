import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

enum AppDialogButtonType { primary, destructive }

class AppDialogButton extends StatelessWidget {
  const AppDialogButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppDialogButtonType.primary,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppDialogButtonType type;

  const AppDialogButton.primary({
    super.key,
    required this.text,
    this.onPressed,
  }) : type = AppDialogButtonType.primary;

  const AppDialogButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
  }) : type = AppDialogButtonType.destructive;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      AppDialogButtonType.primary => _PrimaryButton(
          text: text,
          onPressed: onPressed,
        ),
      AppDialogButtonType.destructive => _DestructiveButton(
          text: text,
          onPressed: onPressed,
        ),
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.grayscale200,
        foregroundColor: AppColors.grayscale600,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.grayscale300;
          }
          return AppColors.grayscale200;
        }),
      ),
      child: Text(
        text,
        style: AppTypography.buttonMain.copyWith(
          color: AppColors.grayscale600,
        ),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error500,
        foregroundColor: AppColors.grayscaleWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.error600;
          }
          return AppColors.error500;
        }),
      ),
      child: Text(
        text,
        style: AppTypography.buttonMain.copyWith(
          color: AppColors.grayscaleWhite,
        ),
      ),
    );
  }
}