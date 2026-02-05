import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_close_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_form.dart';

class QuizDisplayWidget extends HookWidget {
  const QuizDisplayWidget({
    required this.quizCardItem,
    required this.currentIndex,
    required this.totalCards,
    this.isProcessing = false,
    this.onTextPassed,
    this.onSkipPassed,
    this.onClose,
    super.key,
  });

  final QuizCardItem quizCardItem;
  final bool isProcessing;
  final int currentIndex;
  final int totalCards;
  final ValueChanged<String>? onTextPassed;
  final VoidCallback? onSkipPassed;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final editController = useTextEditingController();

    return Column(
      children: [
        const SizedBox(height: 32),
        _Header(
          currentIndex: currentIndex,
          totalCards: totalCards,
          onClose: onClose,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _QuizCard(
                  questionText: quizCardItem.questionText,
                  controller: editController,
                  enabled: !isProcessing,
                  onTextPassed: onTextPassed,
                  onSkipPassed: onSkipPassed,
                ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.currentIndex,
    required this.totalCards,
    this.onClose,
  });

  final int currentIndex;
  final int totalCards;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? currentIndex / totalCards : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AppCloseButton(onPressed: onClose ?? () => context.pop()),
          const SizedBox(width: 8),
          Expanded(
            child: _ProgressBar(progress: progress),
          ),
          const SizedBox(width: 8),
          Text(
            '$currentIndex/$totalCards',
            style: AppTypography.h4.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends HookWidget {
  const _QuizCard({
    required this.questionText,
    required this.controller,
    required this.enabled,
    this.onTextPassed,
    this.onSkipPassed,
  });

  final String questionText;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onTextPassed;
  final VoidCallback? onSkipPassed;

  @override
  Widget build(BuildContext context) {
    final hasText = useListenableSelector(
      controller,
      () => controller.text.isNotEmpty,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: AppTypography.h3.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 24),
          AppTextForm(
            controller: controller,
            hint: localize(context).quizDisplayTypeAnswerHint,
            autofocus: true,
            minLines: 4,
            maxLines: 12,
            textInputAction: TextInputAction.done,
            onSubmitted: onTextPassed,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: hasText
                  ? () => onTextPassed?.call(controller.text)
                  : onSkipPassed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                hasText
                    ? localize(context).quizDisplayAnswerButton
                    : localize(context).quizDisplayDontKnowButton,
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFEBECEF),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}
