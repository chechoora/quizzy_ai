import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

// TODO change UI
class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    super.key,
  });

  final List<QuizCardItem> quizCarList;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: quizCarList
          .map(
            (item) => QuizCardWidget(
              quizCardItem: item,
            ),
          )
          .toList(),
    );
  }
}

class QuizCardWidget extends StatefulWidget {
  const QuizCardWidget({
    required this.quizCardItem,
    super.key,
  });

  final QuizCardItem quizCardItem;

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
        ],
      ),
    );
  }
}
