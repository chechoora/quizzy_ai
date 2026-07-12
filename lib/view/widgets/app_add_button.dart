import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

class AppAddButton extends StatelessWidget {
  const AppAddButton._({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.pressedColor,
    this.onPressed,
    this.size = 56,
  });

  factory AppAddButton({
    Key? key,
    VoidCallback? onPressed,
    double size = 56,
  }) {
    return AppAddButton._(
      key: key,
      onPressed: onPressed,
      size: size,
      backgroundColor: AppColors.primary500,
      pressedColor: AppColors.primary700,
      child: Icon(
        Icons.add,
        color: AppColors.grayscaleWhite,
        size: size * 0.5,
      ),
    );
  }

  factory AppAddButton.generateAi({
    Key? key,
    VoidCallback? onPressed,
    double size = 56,
  }) {
    return AppAddButton._(
      key: key,
      onPressed: onPressed,
      size: size,
      backgroundColor: AppColors.primary500,
      pressedColor: AppColors.primary700,
      child: SvgPicture.asset(
        'assets/icons/stars.svg',
        width: size * 0.5,
        height: size * 0.5,
        colorFilter: const ColorFilter.mode(
          AppColors.grayscaleWhite,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  final VoidCallback? onPressed;
  final double size;
  final Widget child;
  final Color backgroundColor;
  final Color pressedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return pressedColor;
            }
            return backgroundColor;
          }),
        ),
        child: child,
      ),
    );
  }
}
