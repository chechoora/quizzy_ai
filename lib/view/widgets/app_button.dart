import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, tertiary, positive, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leadingIcon;

  // Convenience constructors
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.tertiary({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
  }) : variant = AppButtonVariant.tertiary;

  const AppButton.positive({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
  }) : variant = AppButtonVariant.positive;

  const AppButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
          text: text,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
        ),
      AppButtonVariant.secondary => _SecondaryButton(
          text: text,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
        ),
      AppButtonVariant.tertiary => _TertiaryButton(
          text: text,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
        ),
      AppButtonVariant.positive => _PositiveButton(
          text: text,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
        ),
      AppButtonVariant.destructive => _DestructiveButton(
          text: text,
          onPressed: onPressed,
          leadingIcon: leadingIcon,
        ),
    };
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    this.onPressed,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isEnabled ? AppColors.primary500 : AppColors.grayscale200,
        foregroundColor:
            _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        disabledBackgroundColor: AppColors.grayscale200,
        disabledForegroundColor: AppColors.grayscale400,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grayscale200;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary700;
          }
          return AppColors.primary500;
        }),
      ),
      child: _ButtonContent(
        text: text,
        leadingIcon: leadingIcon,
        textStyle: AppTypography.buttonMain.copyWith(
          color: _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.text,
    this.onPressed,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            _isEnabled ? AppColors.primary500 : AppColors.grayscale400,
        side: BorderSide(
          color: _isEnabled ? AppColors.primary500 : AppColors.grayscale300,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.grayscale300, width: 1.5);
          }
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(color: AppColors.primary700, width: 1.5);
          }
          return const BorderSide(color: AppColors.primary500, width: 1.5);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grayscale400;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary700;
          }
          return AppColors.primary500;
        }),
      ),
      child: _ButtonContent(
        text: text,
        leadingIcon: leadingIcon,
        textStyle: AppTypography.buttonMain.copyWith(
          color: _isEnabled ? AppColors.primary500 : AppColors.grayscale400,
        ),
      ),
    );
  }
}

class _TertiaryButton extends StatelessWidget {
  const _TertiaryButton({
    required this.text,
    this.onPressed,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            _isEnabled ? AppColors.primary500 : AppColors.grayscale400,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grayscale400;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary700;
          }
          return AppColors.primary500;
        }),
      ),
      child: _ButtonContent(
        text: text,
        leadingIcon: leadingIcon,
        textStyle: AppTypography.buttonMain.copyWith(
          color: _isEnabled ? AppColors.primary500 : AppColors.grayscale400,
        ),
      ),
    );
  }
}

class _PositiveButton extends StatelessWidget {
  const _PositiveButton({
    required this.text,
    this.onPressed,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isEnabled ? AppColors.success500 : AppColors.grayscale200,
        foregroundColor:
            _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        disabledBackgroundColor: AppColors.grayscale200,
        disabledForegroundColor: AppColors.grayscale400,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grayscale200;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.success600;
          }
          return AppColors.success500;
        }),
      ),
      child: _ButtonContent(
        text: text,
        leadingIcon: leadingIcon,
        textStyle: AppTypography.buttonMain.copyWith(
          color: _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        ),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.text,
    this.onPressed,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isEnabled ? AppColors.error500 : AppColors.grayscale200,
        foregroundColor:
            _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        disabledBackgroundColor: AppColors.grayscale200,
        disabledForegroundColor: AppColors.grayscale400,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.grayscale200;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.error600;
          }
          return AppColors.error500;
        }),
      ),
      child: _ButtonContent(
        text: text,
        leadingIcon: leadingIcon,
        textStyle: AppTypography.buttonMain.copyWith(
          color: _isEnabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.text,
    required this.textStyle,
    this.leadingIcon,
  });

  final String text;
  final TextStyle textStyle;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon!,
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }
    return Text(text, style: textStyle);
  }
}
