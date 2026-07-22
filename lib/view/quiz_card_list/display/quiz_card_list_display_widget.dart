import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';

class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    this.selectedCardIds = const {},
    this.isSelectionModeActive = false,
    this.onCardSelectionToggle,
    this.onQuizCardEditRequest,
    this.onQuizCardRemoveRequest,
    this.onAddCardRequest,
    super.key,
  });

  final List<QuizCardItem> quizCarList;
  final Set<int> selectedCardIds;
  final bool isSelectionModeActive;
  final ValueChanged<int>? onCardSelectionToggle;
  final ValueChanged<QuizCardItem>? onQuizCardEditRequest;
  final ValueChanged<QuizCardItem>? onQuizCardRemoveRequest;
  final VoidCallback? onAddCardRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: quizCarList.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == quizCarList.length) {
          return _AddCardTile(
            title: l10n.quizCardListAddCardTooltip,
            icon: const Icon(
              Icons.add,
              size: 24,
              color: AppColors.grayscale500,
            ),
            onPressed: onAddCardRequest,
          );
        }
        final item = quizCarList[index];
        final isSelected = selectedCardIds.contains(item.id);
        return QuizCardTile(
          question: item.questionText,
          answer: item.answerText,
          isSelected: isSelected,
          showCheckbox: isSelectionModeActive,
          onTap: isSelectionModeActive
              ? () => onCardSelectionToggle?.call(item.id)
              : null,
          trailing: AppMoreButton(
            actions: [
              AppMoreButtonAction(
                label: l10n.quizCardListEditCardAction,
                icon: 'assets/icons/edit.svg',
                onPressed: () => onQuizCardEditRequest?.call(item),
              ),
              AppMoreButtonAction(
                label: l10n.quizCardListDeleteCardAction,
                icon: 'assets/icons/delete.svg',
                textColor: AppColors.error500,
                onPressed: () => onQuizCardRemoveRequest?.call(item),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuizCardTile extends StatelessWidget {
  const QuizCardTile({
    required this.question,
    required this.answer,
    this.isSelected = false,
    this.showCheckbox = true,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String question;
  final String answer;
  final bool isSelected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.1)
              : AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: AppColors.primary500, width: 1.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.primary500
                      : AppColors.grayscale400,
                  size: 24,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.grayscale600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    answer,
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.grayscale500,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({
    required this.title,
    required this.icon,
    this.onPressed,
  });

  final String title;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
      child: GestureDetector(
        onTap: onPressed,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.grayscale500,
            strokeWidth: 1.5,
            radius: 15,
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.secondaryText.copyWith(
                    color: AppColors.grayscale500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
