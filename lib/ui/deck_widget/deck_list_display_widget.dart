import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class DeckListDisplayWidget extends StatelessWidget {
  const DeckListDisplayWidget({
    required this.deckList,
    super.key,
  });

  final List<DeckItem> deckList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final deck = deckList[index];
        return Card(
          elevation: 4,
          child: Text(deck.title),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 2,
      ),
      itemCount: deckList.length,
    );
  }
}
