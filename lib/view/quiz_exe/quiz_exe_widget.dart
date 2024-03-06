import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/display/quiz_display_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_done_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_exe_cubit.dart';

class QuizExeWidget extends StatefulWidget {
  const QuizExeWidget({
    required this.cards,
    super.key,
  });

  final List<QuizCardItem> cards;

  @override
  State<QuizExeWidget> createState() => _QuizExeWidgetState();
}

class _QuizExeWidgetState extends State<QuizExeWidget> {
  late final QuizExeCubit cubit = QuizExeCubit(
    quizService: getIt<QuizService>(),
    quizCardItems: widget.cards,
    quizMatchBuilder: QuizMatchBuilder(),
  );

  @override
  void initState() {
    cubit.launchQuiz();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<QuizExeCubit, QuizExeState>(
        bloc: cubit,
        builder: (BuildContext context, QuizExeState state) {
          if (state is QuizExeDisplayCardState) {
            final quizCard = state.quizCardItem;
            return QuizDisplayWidget(
              quizCardItem: quizCard,
              onTextPassed: (possibleAnswer) {
                cubit.checkTheAnswer(quizCard, possibleAnswer);
              },
              key: ValueKey(quizCard.id),
            );
          }
          if (state is QuizExeLoadingState) {
            return const SimpleLoadingWidget();
          }
          if (state is QuizDoneState) {
            return QuizDoneWidget(
              quizResults: state.quizResults,
            );
          }
          throw ArgumentError('Wrong state');
        },
        listener: (BuildContext context, QuizExeState state) {},
      ),
    );
  }
}
