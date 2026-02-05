import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_item_widget.dart';

class DeckListDisplayWidget extends StatelessWidget {
  const DeckListDisplayWidget({
    required this.deckList,
    this.onDeckRemoveRequest,
    this.onDeckEditRequest,
    this.onDeckClicked,
    super.key,
  });

  final List<DeckItem> deckList;
  final ValueChanged<DeckItem>? onDeckRemoveRequest;
  final ValueChanged<DeckItem>? onDeckEditRequest;
  final ValueChanged<DeckItem>? onDeckClicked;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(
            height: 32,
          ),
          Text(
            'Quizzy AI',
            style: AppTypography.h1.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final deck = deckList[index];
                return DeckListItemWidget(
                  deck: deck,
                  onDeckRemoveRequest: onDeckRemoveRequest,
                  onDeckEditRequest: onDeckEditRequest,
                  onDeckClicked: onDeckClicked,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                width: 2,
              ),
              itemCount: deckList.length,
            ),
          ),
        ],
      ),
    );
  }
}
