import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/quiz_widget/cubit/quiz_cubit.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final controller = TextEditingController();

  final QuizCubit cubit = QuizCubit();

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: cubit,
      builder: (BuildContext context, state) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(2),
              child: Text('Text fields allow users to type text into an app. '
                  'They are used to build forms, send messages, '
                  'create search experiences, and more.'),
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
                controller: controller,
                decoration: const InputDecoration(hintText: 'Type similar answer', border: InputBorder.none),
              ),
            ),
            ElevatedButton(
              child: const Text('Test'),
              onPressed: () {},
            )
          ],
        );
      },
      listener: (BuildContext context, Object? state) {},
    );
  }
}
