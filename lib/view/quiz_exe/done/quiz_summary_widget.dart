import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:solar_icons/solar_icons.dart';

const _correctAnswerThreshold = 0.7;

class QuizSummaryWidget extends StatelessWidget {
  const QuizSummaryWidget({
    required this.quizResults,
    required this.logger,
    super.key,
  });

  final QuizResults quizResults;
  final Logger logger;

  int get _total => quizResults.quizMatchList.length;

  int get _correctCount => quizResults.quizMatchList
      .where((match) => match.ratio >= _correctAnswerThreshold)
      .length;

  int get _averageScore {
    if (_total == 0) return 0;
    final sum =
        quizResults.quizMatchList.fold<double>(0, (s, m) => s + m.ratio);
    return ((sum / _total) * 100).round();
  }

  String get _headline {
    if (_total == 0) return "You're doing great, keep going!";
    final accuracy = _correctCount / _total;
    if (accuracy >= 0.8) return "Amazing job, you nailed it!";
    if (accuracy >= 0.5) return "You're doing great, keep going!";
    return "Keep practicing, you'll get there!";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.topLeft,
          child: AppCircleIconButton(
            icon: SolarIconsOutline.closeCircle,
            onPressed: () => context.pop(),
          ),
        ),
        const Spacer(),
        Image.asset(
          'assets/images/quiz_done.png',
          height: 220,
          fit: BoxFit.fitHeight,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _headline,
            textAlign: TextAlign.center,
            style: AppTypography.h1,
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Correct answers',
                  value: '$_correctCount/$_total',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatTile(
                  icon: Icons.percent_rounded,
                  label: 'Score',
                  value: '$_averageScore/100',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  text: 'Play Another Deck',
                  leadingIcon: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.grayscaleWhite,
                  ),
                  onPressed: () {
                    logger.i('Play another deck pressed, navigating home');
                    context.go(HomeRoute().path);
                  },
                ),
              ),
              const SizedBox(height: 8),
              AppButton.tertiary(
                text: 'Review answers',
                onPressed: () {
                  logger.i('Review answers pressed, opening review screen');
                  context.push(QuizReviewRoute().path, extra: quizResults);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.secondaryText.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary500),
              const SizedBox(width: 8),
              Text(
                value,
                style: AppTypography.h3.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
