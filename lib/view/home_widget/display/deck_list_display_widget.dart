import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

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
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Text(
                    deck.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
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
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            onDeckEditRequest?.call(deck);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).primaryColor,
                          ),
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
            onTap: () {
              onDeckClicked?.call(deck);
            },
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
