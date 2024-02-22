import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class DeckListDisplayWidget extends StatelessWidget {
  const DeckListDisplayWidget({
    required this.deckList,
    this.onDeckRemoveRequest,
    this.onDeckEditRequest,
    super.key,
  });

  final List<DeckItem> deckList;
  final ValueChanged<DeckItem>? onDeckRemoveRequest;
  final ValueChanged<DeckItem>? onDeckEditRequest;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final deck = deckList[index];
        return Card(
          elevation: 4,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Text(deck.title),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 8),
                  alignment: Alignment.centerRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          onDeckEditRequest?.call(deck);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          onDeckRemoveRequest?.call(deck);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 2,
      ),
      itemCount: deckList.length,
    );
  }
}
