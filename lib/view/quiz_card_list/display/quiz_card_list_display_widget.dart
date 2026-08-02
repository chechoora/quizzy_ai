import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/stats/model/item_stats.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';

class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    this.deckStats,
    this.selectedCardIds = const {},
    this.isSelectionModeActive = false,
    this.isAnswerVisible = false,
    this.switchSides = false,
    this.onCardSelectionToggle,
    this.onQuizCardEditRequest,
    this.onQuizCardRemoveRequest,
    super.key,
  });

  final List<QuizCardItem> quizCarList;
  final ItemStats? deckStats;
  final Set<int> selectedCardIds;
  final bool isSelectionModeActive;
  final bool isAnswerVisible;
  final bool switchSides;
  final ValueChanged<int>? onCardSelectionToggle;
  final ValueChanged<QuizCardItem>? onQuizCardEditRequest;
  final ValueChanged<QuizCardItem>? onQuizCardRemoveRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final stats = deckStats;
    final hasStats = stats != null;
    final itemCount = quizCarList.length + (hasStats ? 1 : 0);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (hasStats && index == 0) {
          return Builder(builder: (context) {
            final rows = _buildStatsRows(stats, l10n);
            if (rows.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppStatsCard(
                rows: rows,
                accuracyLabel: l10n.quizCardListStatsAccuracy,
                attemptsLabel: l10n.quizCardListStatsAttempts,
                bestStreakLabel: l10n.quizCardListStatsBestStreak,
                lastPlayedLabel: l10n.quizCardListStatsLastPlayed,
                lastPlayedValue: _formatLastPlayed(stats.lastPlayedAt, l10n),
              ),
            );
          });
        }
        final cardIndex = hasStats ? index - 1 : index;
        final item = quizCarList[cardIndex];
        final isSelected = selectedCardIds.contains(item.id);
        final itemStats = item.stats;
        final hasCardStats =
            itemStats != null && _buildStatsRows(itemStats, l10n).isNotEmpty;
        return QuizCardTile(
          question: switchSides ? item.answerText : item.questionText,
          answer: switchSides ? item.questionText : item.answerText,
          stats: item.stats,
          isSelected: isSelected,
          showCheckbox: isSelectionModeActive,
          isAnswerVisible: isAnswerVisible,
          onTap: isSelectionModeActive
              ? () => onCardSelectionToggle?.call(item.id)
              : null,
          trailing: AppMoreButton(
            actions: [
              if (hasCardStats)
                AppMoreButtonAction(
                  label: l10n.quizCardListShowStatsAction,
                  icon: 'assets/icons/stats.svg',
                  onPressed: () =>
                      _showCardStatsBottomSheet(context, itemStats, l10n),
                ),
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

List<AppStatsPeriodRow> _buildStatsRows(
    ItemStats stats, LocalizedStrings l10n) {
  final rows = <AppStatsPeriodRow>[];
  if (stats.accuracy.week != null) {
    rows.add(AppStatsPeriodRow(
      label: l10n.quizCardListStatsWeek,
      accuracyRatio: stats.accuracy.week,
      attempts: stats.attempts.week,
      bestStreak: stats.bestStreak.week,
    ));
  }
  if (stats.accuracy.month != null) {
    rows.add(AppStatsPeriodRow(
      label: l10n.quizCardListStatsMonth,
      accuracyRatio: stats.accuracy.month,
      attempts: stats.attempts.month,
      bestStreak: stats.bestStreak.month,
    ));
  }
  if (stats.accuracy.year != null) {
    rows.add(AppStatsPeriodRow(
      label: l10n.quizCardListStatsYear,
      accuracyRatio: stats.accuracy.year,
      attempts: stats.attempts.year,
      bestStreak: stats.bestStreak.year,
    ));
  }
  return rows;
}

String _formatLastPlayed(DateTime? lastPlayedAt, LocalizedStrings l10n) {
  if (lastPlayedAt == null) return l10n.quizCardListStatsNeverPlayed;
  return DateFormat.yMMMd().format(lastPlayedAt);
}

void _showCardStatsBottomSheet(
  BuildContext context,
  ItemStats stats,
  LocalizedStrings l10n,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => AppStatsBottomSheet(
      title: l10n.quizCardListCardStatsTitle,
      rows: _buildStatsRows(stats, l10n),
      accuracyLabel: l10n.quizCardListStatsAccuracy,
      attemptsLabel: l10n.quizCardListStatsAttempts,
      bestStreakLabel: l10n.quizCardListStatsBestStreak,
      lastPlayedLabel: l10n.quizCardListStatsLastPlayed,
      lastPlayedValue: _formatLastPlayed(stats.lastPlayedAt, l10n),
    ),
  );
}

class QuizCardTile extends StatelessWidget {
  const QuizCardTile({
    required this.question,
    required this.answer,
    this.stats,
    this.isSelected = false,
    this.showCheckbox = true,
    this.isAnswerVisible = false,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String question;
  final String answer;
  final ItemStats? stats;
  final bool isSelected;
  final bool showCheckbox;
  final bool isAnswerVisible;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
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
                  if (isAnswerVisible) ...[
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
                  if (stats != null) ...[
                    const SizedBox(height: 8),
                    AppStatsSummaryRow(
                      accuracyLabel: l10n.quizCardListStatsAccuracy,
                      accuracyRatio: stats!.accuracy.week,
                      attemptsLabel: l10n.quizCardListStatsAttempts,
                      attempts: stats!.attempts.week,
                      bestStreakLabel: l10n.quizCardListStatsBestStreak,
                      bestStreak: stats!.bestStreak.week,
                      lastPlayedLabel: l10n.quizCardListStatsLastPlayed,
                      lastPlayedValue: _formatLastPlayed(
                        stats!.lastPlayedAt,
                        l10n,
                      ),
                    ),
                  ],
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

