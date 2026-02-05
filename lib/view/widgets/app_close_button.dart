import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 2,
          shadowColor: const Color(0xFFE7E7E7).withValues(alpha: 0.25),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.grayscale100;
            }
            return AppColors.grayscaleWhite;
          }),
        ),
        child: const Icon(
          Icons.close,
          color: AppColors.grayscale600,
          size: 20,
        ),
      ),
    );
  }
}
