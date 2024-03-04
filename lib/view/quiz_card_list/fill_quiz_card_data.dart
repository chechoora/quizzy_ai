import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_request_item.dart';

class FillQuizCardData extends StatefulWidget {
  const FillQuizCardData({
    this.onValueChange,
    super.key,
  });

  final ValueChanged<QuizCardRequestItem>? onValueChange;

  @override
  State<FillQuizCardData> createState() => _FillQuizCardDataState();
}

class _FillQuizCardDataState extends State<FillQuizCardData> {
  String question = "";
  String answer = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Enter question",
            border: OutlineInputBorder(),
          ),
          onChanged: (questionText) {
            question = questionText;
            _notifyValue();
          },
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: "Enter answer",
            border: OutlineInputBorder(),
          ),
          onChanged: (answerText) {
            answer = answerText;
            _notifyValue();
          },
        )
      ],
    );
  }

  void _notifyValue() {
    widget.onValueChange?.call(
      QuizCardRequestItem(
        question,
        answer,
      ),
    );
  }
}
