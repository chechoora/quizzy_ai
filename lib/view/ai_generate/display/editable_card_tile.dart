import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/ai_generate/cubit/ai_generate_cubit.dart';
import 'package:poc_ai_quiz/view/widgets/app_more_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_form.dart';

/// A single editable AI-generated card: inline question + answer fields with a
/// delete action. Controllers are seeded once from [card]; edits are reported
/// back via [onChanged] without the parent rebuilding this tile.
class EditableCardTile extends HookWidget {
  const EditableCardTile({
    required this.card,
    required this.index,
    required this.onQuestionChanged,
    required this.onAnswerChanged,
    required this.onDelete,
    super.key,
  });

  final AiGenerateCard card;
  final int index;
  final ValueChanged<String> onQuestionChanged;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final questionController = useTextEditingController(text: card.question);
    final answerController = useTextEditingController(text: card.answer);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.aiGenerateCardNumber(index + 1),
                style: AppTypography.smallText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
              const Spacer(),
              AppMoreButton(
                actions: [
                  AppMoreButtonAction(
                    label: l10n.aiGenerateDeleteCardLabel,
                    icon: 'assets/icons/delete.svg',
                    textColor: AppColors.error500,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiGenerateCardQuestionLabel,
            style: AppTypography.smallText.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
          const SizedBox(height: 4),
          AppTextForm(
            controller: questionController,
            hint: l10n.aiGenerateCardQuestionHint,
            minLines: 1,
            maxLines: 4,
            onChanged: onQuestionChanged,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aiGenerateCardAnswerLabel,
            style: AppTypography.smallText.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
          const SizedBox(height: 4),
          AppTextForm(
            controller: answerController,
            hint: l10n.aiGenerateCardAnswerHint,
            minLines: 1,
            maxLines: 4,
            onChanged: onAnswerChanged,
          ),
        ],
      ),
    );
  }
}
