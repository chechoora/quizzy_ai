import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_more_button.dart';

class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    this.selectedCardIds = const {},
    this.onCardSelectionToggle,
    this.onQuizCardEditRequest,
    this.onQuizCardRemoveRequest,
    this.onAddCardRequest,
    super.key,
  });

  final List<QuizCardItemWithPremium> quizCarList;
  final Set<int> selectedCardIds;
  final ValueChanged<int>? onCardSelectionToggle;
  final ValueChanged<QuizCardItem>? onQuizCardEditRequest;
  final ValueChanged<QuizCardItem>? onQuizCardRemoveRequest;
  final VoidCallback? onAddCardRequest;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: quizCarList.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == quizCarList.length) {
          return _AddCardTile(onPressed: onAddCardRequest);
        }
        final item = quizCarList[index];
        final isSelected = selectedCardIds.contains(item.id);
        return _QuizCardTile(
          quizCardItem: item,
          isSelected: isSelected,
          onTap: () => onCardSelectionToggle?.call(item.id),
          onEditPressed:
              item.isLocked ? null : () => onQuizCardEditRequest?.call(item),
          onDeletePressed:
              item.isLocked ? null : () => onQuizCardRemoveRequest?.call(item),
        );
      },
    );
  }
}

class _QuizCardTile extends StatelessWidget {
  const _QuizCardTile({
    required this.quizCardItem,
    this.isSelected = false,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final QuizCardItemWithPremium quizCardItem;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final isLocked = quizCardItem.isLocked;
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
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
              if (!isLocked)
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
                      quizCardItem.questionText,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.grayscale600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quizCardItem.answerText,
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.grayscale500,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isLocked)
                const Icon(
                  Icons.lock,
                  size: 24,
                  color: AppColors.grayscale500,
                )
              else
                AppMoreButton(
                  actions: [
                    AppMoreButtonAction(
                      label: l10n.quizCardListEditCardAction,
                      icon: 'assets/icons/edit.svg',
                      onPressed: () => onEditPressed?.call(),
                    ),
                    AppMoreButtonAction(
                      label: l10n.quizCardListDeleteCardAction,
                      icon: 'assets/icons/delete.svg',
                      textColor: AppColors.error500,
                      onPressed: () => onDeletePressed?.call(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
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
                const Icon(
                  Icons.add,
                  size: 24,
                  color: AppColors.grayscale500,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.quizCardListAddCardTooltip,
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
