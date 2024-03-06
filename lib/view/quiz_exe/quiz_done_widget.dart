import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/model/quiz_results.dart';

class QuizDoneWidget extends StatelessWidget {
  const QuizDoneWidget({
    required this.quizResults,
    super.key,
  });

  final QuizResults quizResults;

  @override
  Widget build(BuildContext context) {
    final quizMatchList = quizResults.quizMatchList;
    return Column(
      children: [
        const Text('Cards done, here is your results'),
        Expanded(
          child: ListView.builder(
            itemCount: quizMatchList.length,
            itemBuilder: (context, index) {
              return QuizMatchWidget(
                quizAnswerMatch: quizMatchList[index],
              );
            },
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        )
      ],
    );
  }
}

class QuizMatchWidget extends StatelessWidget {
  const QuizMatchWidget({
    required this.quizAnswerMatch,
    super.key,
  });

  final QuizAnswerMatch quizAnswerMatch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Question: ${quizAnswerMatch.question}",
          ),
          Text(
            "Answer: ${quizAnswerMatch.correctAnswer}",
          ),
          Text(
            "Your answer: ${quizAnswerMatch.yourAnswer}",
          ),
          Text(
            "Match: ${(quizAnswerMatch.ratio * 100).toInt()}",
          ),
        ],
      ),
    );
  }
}
