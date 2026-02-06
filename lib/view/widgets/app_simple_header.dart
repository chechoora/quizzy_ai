import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_back_button.dart';

class AppSimpleHeader extends StatelessWidget {
  const AppSimpleHeader({
    required this.title,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
      child: Row(
        children: [
          AppBackButton(onPressed: onBackPressed),
          Expanded(
            child: Text(
              title,
              style: AppTypography.h2.copyWith(
                color: AppColors.grayscale600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}