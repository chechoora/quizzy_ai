import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

class AppMoreButtonAction {
  const AppMoreButtonAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconColor,
    this.textColor,
  });

  final String label;
  final VoidCallback onPressed;
  final String? icon;
  final Color? iconColor;
  final Color? textColor;
}

class AppMoreButton extends StatelessWidget {
  const AppMoreButton({
    required this.actions,
    super.key,
  });

  final List<AppMoreButtonAction> actions;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (index) => actions[index].onPressed(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.grayscaleWhite,
      padding: EdgeInsets.zero,
      iconSize: 24,
      itemBuilder: (context) => [
        for (var i = 0; i < actions.length; i++)
          PopupMenuItem(
            value: i,
            child: Row(
              children: [
                if (actions[i].icon != null)
                  SvgPicture.asset(
                    actions[i].icon!,
                    width: 20,
                    height: 20,
                    colorFilter: actions[i].iconColor != null
                        ? ColorFilter.mode(
                            actions[i].iconColor!,
                            BlendMode.srcIn,
                          )
                        : null,
                  ),
                if (actions[i].icon != null) const SizedBox(width: 12),
                Text(
                  actions[i].label,
                  style: AppTypography.mainText.copyWith(
                    color: actions[i].textColor ?? AppColors.grayscale600,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(),
            const SizedBox(height: 3),
            _buildDot(),
            const SizedBox(height: 3),
            _buildDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.grayscale500,
        shape: BoxShape.circle,
      ),
    );
  }
}
