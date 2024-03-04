import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/model/deck_request_item.dart';

class FillQuizCardData extends StatefulWidget {
  const FillQuizCardData({
    this.onValueChange,
    this.cardItemForEdit,
    super.key,
  });

  final ValueChanged<QuizCardRequestItem>? onValueChange;
  final QuizCardItem? cardItemForEdit;

  @override
  State<FillQuizCardData> createState() => _FillQuizCardDataState();
}

class _FillQuizCardDataState extends State<FillQuizCardData> {
  String question = "";
  String answer = "";

  @override
  void initState() {
    question = widget.cardItemForEdit?.questionText ?? '';
    answer = widget.cardItemForEdit?.answerText ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: question,
          decoration: const InputDecoration(
            labelText: "Enter question",
            border: OutlineInputBorder(),
          ),
          onChanged: (questionText) {
            question = questionText;
            _notifyValue();
          },
        ),
        TextFormField(
          initialValue: answer,
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
