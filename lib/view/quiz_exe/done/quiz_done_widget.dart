import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';

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
        _BottomQuizDoneBar(
          onCloseRequest: () {
            context.pop();
          },
        ),
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
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
          if (quizAnswerMatch.explanation != null)
            Text(
              "Explanation: ${quizAnswerMatch.explanation}",
            ),
        ],
      ),
    );
  }
}

class _BottomQuizDoneBar extends StatelessWidget {
  const _BottomQuizDoneBar({
    this.onCloseRequest,
  });

  final VoidCallback? onCloseRequest;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            tooltip: 'Close',
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onCloseRequest,
          ),
        ],
      ),
    );
  }
}
