import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/view/create_card/display/create_card_display_widget.dart';

class CreateCardWidget extends StatefulWidget {
  const CreateCardWidget({
    this.cardToEdit,
    super.key,
  });

  final QuizCardItem? cardToEdit;

  @override
  State<CreateCardWidget> createState() => _CreateCardWidgetState();
}

class _CreateCardWidgetState extends State<CreateCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CreateCardDisplayWidget(
          cardToEdit: widget.cardToEdit,
        ),
      ),
    );
  }
}
