import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 40,
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
              return Colors.transparent;
            }
            return AppColors.grayscaleWhite;
          }),
        ),
        child: Icon(
          Icons.chevron_left,
          color: AppColors.grayscale600,
          size: size * 0.6,
        ),
      ),
    );
  }
}