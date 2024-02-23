import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class QuizCardListDisplayWidget extends StatelessWidget {
  const QuizCardListDisplayWidget({
    required this.quizCarList,
    super.key,
  });

  final List<QuizCardItem> quizCarList;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
