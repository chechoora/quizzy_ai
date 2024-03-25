import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';

class QuizDisplayWidget extends StatefulWidget {
  const QuizDisplayWidget({
    required this.quizCardItem,
    this.onTextPassed,
    this.onSkipPassed,
    super.key,
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
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.quizCardItem.questionText,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: TextField(
                  autofocus: true,
                  maxLines: null,
                  controller: editController,
                  decoration: const InputDecoration(hintText: 'Type answer', border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
        _BottomQuizExeBar(
          onCloseRequest: () {
            context.pop();
          },
          onCheckRequest: () {
            widget.onTextPassed?.call(editController.text);
          },
        ),
      ],
    );
  }
}

class _BottomQuizExeBar extends StatelessWidget {
  const _BottomQuizExeBar({
    this.onCloseRequest,
    this.onCheckRequest,
    this.onBackRequest,
    this.onForwardRequest,
  });

  final VoidCallback? onCloseRequest;
  final VoidCallback? onCheckRequest;
  final VoidCallback? onBackRequest;
  final VoidCallback? onForwardRequest;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Close',
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onCloseRequest,
          ),
          IconButton(
            tooltip: 'Check',
            icon: Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onCheckRequest,
          ),
          // IconButton(
          //   tooltip: 'Backwards',
          //   icon: Icon(
          //     Icons.arrow_back_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          //   onPressed: onBackRequest,
          // ),
          // IconButton(
          //   tooltip: 'Forward',
          //   icon: Icon(
          //     Icons.arrow_forward_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          //   onPressed: onForwardRequest,
          // ),
        ],
      ),
    );
  }
}
