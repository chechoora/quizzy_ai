import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

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
    return Card(
      child: Column(
        children: [
          Text(widget.quizCardItem.questionText),
          const Divider(
            thickness: 1.0,
          ),
          Text(widget.quizCardItem.answerText),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                  ),
                  onPressed: () {
                    widget.onQuizCardEditRequest?.call();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                  ),
                  onPressed: () {
                    widget.onQuizCardRemoveRequest?.call();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
