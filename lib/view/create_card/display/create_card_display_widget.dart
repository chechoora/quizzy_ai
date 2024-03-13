import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/model/deck_request_item.dart';
import 'package:poc_ai_quiz/util/view/bottom_save_bar.dart';

class CreateCardDisplayWidget extends StatefulWidget {
  const CreateCardDisplayWidget({
    this.cardToEdit,
    super.key,
  });

  final QuizCardItem? cardToEdit;

  @override
  State<CreateCardDisplayWidget> createState() => _CreateCardDisplayWidgetState();
}

class _CreateCardDisplayWidgetState extends State<CreateCardDisplayWidget> {
  late final questionController = TextEditingController(
    text: widget.cardToEdit?.questionText,
  );
  late final answerController = TextEditingController(
    text: widget.cardToEdit?.answerText,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add question',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                height: 120,
                margin: const EdgeInsets.all(8),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  controller: questionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add answer',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                height: 120,
                margin: const EdgeInsets.all(8),
                child: TextFormField(
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  controller: answerController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        BottomSaveBar(
          onBackRequest: () {
            context.pop();
          },
          onSaveRequest: () {
            context.pop(
              QuizCardRequestItem(
                question: questionController.text,
                answer: answerController.text,
              ),
            );
          },
        ),
      ],
    );
  }
}
