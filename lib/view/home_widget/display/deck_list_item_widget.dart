import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_more_button.dart';

class DeckListItemWidget extends StatelessWidget {
  const DeckListItemWidget({
    required this.deck,
    this.onDeckRemoveRequest,
    this.onDeckEditRequest,
    this.onDeckClicked,
    super.key,
  });

  final DeckItem deck;
  final ValueChanged<DeckItem>? onDeckRemoveRequest;
  final ValueChanged<DeckItem>? onDeckEditRequest;
  final ValueChanged<DeckItem>? onDeckClicked;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: AppColors.grayscaleWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: GestureDetector(
        onTap: () => onDeckClicked?.call(deck),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/folder.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  deck.title,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.grayscale600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppMoreButton(
                actions: [
                  AppMoreButtonAction(
                    label: l10n.homeEditDeckAction,
                    icon: 'assets/icons/edit.svg',
                    onPressed: () => onDeckEditRequest?.call(deck),
                  ),
                  AppMoreButtonAction(
                    label: l10n.homeDeleteDeckAction,
                    icon: 'assets/icons/delete.svg',
                    textColor: AppColors.error500,
                    onPressed: () => onDeckRemoveRequest?.call(deck),
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