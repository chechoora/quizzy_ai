import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

class AppAddButton extends StatelessWidget {
  const AppAddButton({
    super.key,
    this.onPressed,
    this.size = 56,
  });

  final VoidCallback? onPressed;
  final double size;

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
              return AppColors.primary700;
            }
            return AppColors.primary500;
          }),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.grayscaleWhite,
          size: size * 0.5,
        ),
      ),
    );
  }
}