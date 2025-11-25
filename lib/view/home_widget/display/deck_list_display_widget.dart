import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
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
    return ListView.separated(
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
    );
  }
}
