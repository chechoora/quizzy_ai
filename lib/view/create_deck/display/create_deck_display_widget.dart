import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/view/bottom_save_bar.dart';
import 'package:poc_ai_quiz/view/create_card/display/create_card_display_widget.dart';

class CreateDeckDisplay extends StatefulWidget {
  const CreateDeckDisplay({
    this.deckName,
    super.key,
  });

  final String? deckName;

  @override
  State<CreateDeckDisplay> createState() => _CreateDeckDisplayState();
}

class _CreateDeckDisplayState extends State<CreateDeckDisplay> {
  late final controller = TextEditingController(text: widget.deckName);

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
                  localize(context).createDeckTitleLabel,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: TextFormField(
                  maxLength: deckNameLimit,
                  textCapitalization: TextCapitalization.sentences,
                  controller: controller,
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
            final text = controller.text;
            if (text.isNotEmpty) {
              context.pop(text);
            }
          },
        ),
      ],
    );
  }
}
