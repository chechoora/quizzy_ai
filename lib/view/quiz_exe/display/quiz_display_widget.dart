import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/util/view/answer_validator_dropdown.dart';
import 'package:poc_ai_quiz/view/create_card/display/create_card_display_widget.dart';

class QuizDisplayWidget extends StatefulWidget {
  const QuizDisplayWidget({
    required this.quizCardItem,
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
    this.isProcessing = false,
    this.onTextPassed,
    this.onSkipPassed,
    super.key,
  });

  final QuizCardItem quizCardItem;
  final bool isProcessing;
  final ValueChanged<String>? onTextPassed;
  final VoidCallback? onSkipPassed;
  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onValidatorChanged;

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
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.quizCardItem.questionText,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      height: 120,
                      child: TextField(
                        maxLength: answerLimit,
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: true,
                        maxLines: null,
                        controller: editController,
                        enabled: !widget.isProcessing,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type answer',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .inversePrimary
                                .withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        _BottomQuizExeBar(
          onCloseRequest: () {
            context.pop();
          },
          onCheckRequest: widget.isProcessing
              ? null
              : () {
                  widget.onTextPassed?.call(editController.text);
                },
          trailing: widget.validators.isEmpty
              ? Container()
              : AnswerValidatorDropdown(
                  selectedValidator: widget.selectedValidator,
                  validators: widget.validators,
                  onValidatorChanged: widget.onValidatorChanged,
                ),
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
    this.trailing,
  });

  final VoidCallback? onCloseRequest;
  final VoidCallback? onCheckRequest;
  final VoidCallback? onBackRequest;
  final VoidCallback? onForwardRequest;
  final Widget? trailing;

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
          Expanded(child: trailing ?? const SizedBox.shrink()),
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
