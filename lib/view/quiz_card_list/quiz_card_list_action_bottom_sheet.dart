import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:solar_icons/solar_icons.dart';

enum QuizCardListHeaderAction { addCard, aiDeckEdit }

Future<QuizCardListHeaderAction?> showQuizCardListActionBottomSheet(
  BuildContext context,
) {
  return showModalBottomSheet<QuizCardListHeaderAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => const _QuizCardListActionBottomSheet(),
  );
}

class _QuizCardListActionBottomSheet extends StatelessWidget {
  const _QuizCardListActionBottomSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return AppContentBottomSheet(
      title: l10n.quizCardListActionSheetTitle,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionOption(
              icon: SolarIconsOutline.addSquare,
              title: l10n.quizCardListAddCardOption,
              onTap: () => Navigator.of(context)
                  .pop(QuizCardListHeaderAction.addCard),
            ),
            const SizedBox(height: 24),
            _ActionOption(
              icon: SolarIconsOutline.magicStick_3,
              title: l10n.quizCardListAiDeckEditOption,
              onTap: () => Navigator.of(context)
                  .pop(QuizCardListHeaderAction.aiDeckEdit),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionOption extends StatelessWidget {
  const _ActionOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.grayscale600,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.h4.copyWith(color: AppColors.grayscale600),
            ),
          ),
        ],
      ),
    );
  }
}
