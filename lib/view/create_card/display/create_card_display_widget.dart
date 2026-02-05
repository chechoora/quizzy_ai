import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_back_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_form.dart';

class CreateCardDisplayWidget extends HookWidget {
  const CreateCardDisplayWidget({
    this.cardToEdit,
    super.key,
  });

  final QuizCardItem? cardToEdit;

  @override
  Widget build(BuildContext context) {
    final questionController = useTextEditingController(
      text: cardToEdit?.questionText,
    );
    final answerController = useTextEditingController(
      text: cardToEdit?.answerText,
    );

    final questionText = useState(cardToEdit?.questionText ?? '');
    final answerText = useState(cardToEdit?.answerText ?? '');

    final isFormValid =
        questionText.value.isNotEmpty && answerText.value.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _Header(
                    onBackPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 24),
                  _TextAreaSection(
                    label: 'Enter question',
                    hint: 'Add your question here',
                    controller: questionController,
                    onChanged: (value) => questionText.value = value,
                  ),
                  const SizedBox(height: 24),
                  _TextAreaSection(
                    label: 'Enter answer',
                    hint: 'Add your answer here',
                    controller: answerController,
                    onChanged: (value) => answerText.value = value,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AppButton.primary(
                      text: 'Add Card',
                      onPressed: isFormValid
                          ? () {
                              context.pop(
                                QuizCardRequestItem(
                                  question: questionController.text,
                                  answer: answerController.text,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBackPressed,
  });

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(
              onPressed: onBackPressed,
            ),
          ),
          Center(
            child: Text(
              'Create card',
              style: AppTypography.h2.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAreaSection extends StatelessWidget {
  const _TextAreaSection({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.h4.copyWith(
            color: AppColors.grayscale600,
          ),
        ),
        const SizedBox(height: 12),
        AppTextForm(
          controller: controller,
          hint: hint,
          onChanged: onChanged,
          minLines: 4,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}

const deckNameLimit = 30;
const questionLimit = 200;
const answerLimit = 50;
