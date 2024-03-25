import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';

// TODO change UI
class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    this.onQuizCardEditRequest,
    this.onQuizCardRemoveRequest,
    super.key,
  });

  final List<QuizCardItem> quizCarList;
  final ValueChanged<QuizCardItem>? onQuizCardEditRequest;
  final ValueChanged<QuizCardItem>? onQuizCardRemoveRequest;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: quizCarList
          .map(
            (item) => QuizCardWidget(
              quizCardItem: item,
              onQuizCardEditRequest: () {
                onQuizCardEditRequest?.call(item);
              },
              onQuizCardRemoveRequest: () {
                onQuizCardRemoveRequest?.call(item);
              },
            ),
          )
          .toList(),
    );
  }
}

class QuizCardWidget extends StatefulWidget {
  const QuizCardWidget({
    required this.quizCardItem,
    this.onQuizCardEditRequest,
    this.onQuizCardRemoveRequest,
    super.key,
  });

  final QuizCardItem quizCardItem;
  final VoidCallback? onQuizCardEditRequest;
  final VoidCallback? onQuizCardRemoveRequest;

  @override
  State<QuizCardWidget> createState() => _QuizCardWidgetState();
}

class _QuizCardWidgetState extends State<QuizCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              alignment: Alignment.center,
              child: Text(widget.quizCardItem.questionText),
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 1.0,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              alignment: Alignment.center,
              child: Text(widget.quizCardItem.answerText),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  widget.onQuizCardEditRequest?.call();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  widget.onQuizCardRemoveRequest?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
