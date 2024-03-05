import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class QuizDisplayWidget extends StatefulWidget {
  const QuizDisplayWidget({
    required this.quizCardItem,
    super.key,
    this.onTextPassed,
    this.onSkipPassed,
  });

  final QuizCardItem quizCardItem;
  final ValueChanged<String>? onTextPassed;
  final VoidCallback? onSkipPassed;

  @override
  State<QuizDisplayWidget> createState() => _QuizDisplayWidgetState();
}

class _QuizDisplayWidgetState extends State<QuizDisplayWidget> {
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            widget.quizCardItem.questionText,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
          alignment: Alignment.topLeft,
          height: 120,
          child: TextField(
            maxLines: null,
            controller: editController,
            decoration: const InputDecoration(hintText: 'Type answer', border: InputBorder.none),
          ),
        ),
        ElevatedButton(
          child: const Text('Test'),
          onPressed: () {
            widget.onTextPassed?.call(editController.text);
          },
        )
      ],
    );
  }
}
