import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/quiz_serive/quiz_service.dart';
import 'package:poc_ai_quiz/quiz_widget/cubit/quiz_cubit.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final editController = TextEditingController();

  final QuizCubit cubit = QuizCubit(getIt<QuizService>());

  static const textToCompare =
      'Text fields allow users to type text into an app. They are used to build forms, send messages, create search experiences, and more.';

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      bloc: cubit,
      buildWhen: (oldState, newState) {
        return newState is QuizIdleState;
      },
      builder: (BuildContext context, state) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(2),
              child: Text(textToCompare),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              height: 120,
              child: TextField(
                maxLines: null,
                controller: editController,
                decoration: const InputDecoration(hintText: 'Type similar answer', border: InputBorder.none),
              ),
            ),
            ElevatedButton(
              child: const Text('Test'),
              onPressed: () {
                cubit.checkText(
                  initialText: textToCompare,
                  inputText: editController.text,
                );
              },
            )
          ],
        );
      },
      listenWhen: (oldState, newState) {
        return newState is QuizResultState;
      },
      listener: (BuildContext context, QuizState state) {
        if (state is QuizResultState) {
          context.showSnackBar(state.isSimilarEnough ? "yay" : "nay");
        }
      },
    );
  }
}
