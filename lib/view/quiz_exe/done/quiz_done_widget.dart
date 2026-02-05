import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_close_button.dart'
    show AppCloseButton;

class QuizDoneWidget extends StatelessWidget {
  const QuizDoneWidget({
    required this.quizResults,
    super.key,
  });

  final QuizResults quizResults;

  @override
  Widget build(BuildContext context) {
    final quizMatchList = quizResults.quizMatchList;
    return Column(
      children: [
        const SizedBox(height: 32),
        _Header(
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: quizMatchList.length,
            itemBuilder: (context, index) {
              return QuizMatchWidget(
                quizAnswerMatch: quizMatchList[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class QuizMatchWidget extends StatelessWidget {
  const QuizMatchWidget({
    required this.quizAnswerMatch,
    super.key,
  });

  final QuizAnswerMatch quizAnswerMatch;

  @override
  Widget build(BuildContext context) {
    final isLowRatio = quizAnswerMatch.ratio < 0.7;
    final textColor = isLowRatio ? AppColors.error600 : AppColors.success600;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(15),
          border: isLowRatio
              ? Border.all(color: AppColors.error600, width: 1.5)
              : Border.all(color: AppColors.success600, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Question: ${quizAnswerMatch.question}",
            style: AppTypography.h4.copyWith(color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Answer: ${quizAnswerMatch.correctAnswer}",
            style: AppTypography.secondaryText.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your answer: ${quizAnswerMatch.yourAnswer}",
            style: AppTypography.secondaryText.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            "Match: ${(quizAnswerMatch.ratio * 100).toInt()}%",
            style: AppTypography.secondaryText.copyWith(color: textColor),
          ),
          if (quizAnswerMatch.explanation != null) ...[
            const SizedBox(height: 4),
            Text(
              "Explanation: ${quizAnswerMatch.explanation}",
              style: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AppCloseButton(onPressed: onClose ?? () => context.pop()),
          const SizedBox(width: 16),
          Text(
            'Review your progress',
            style: AppTypography.h2,
          ),
        ],
      ),
    );
  }
}
