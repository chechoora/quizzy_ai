import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/display/quiz_display_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/done/quiz_done_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_exe_cubit.dart';

class QuizExeWidget extends HookWidget {
  const QuizExeWidget({
    required this.cards,
    super.key,
  });

  final List<QuizCardItem> cards;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => QuizExeCubit(
        quizService: getIt<QuizService>(),
        quizCardItems: cards,
        quizMatchBuilder: QuizMatchBuilder(),
      ),
    );

    useEffect(
      () {
        cubit.launchQuiz();
        return null;
      },
      [cubit],
    );

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<QuizExeCubit, QuizExeState>(
          bloc: cubit,
          builder: (BuildContext context, state) {
            final isQuizDone = state is QuizDoneState;
            return Text(
              isQuizDone ? "Quiz Finished" : "Quiz in Progress",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<QuizExeCubit, QuizExeState>(
        bloc: cubit,
        buildWhen: (previous, current) => current is! QuizExeErrorState,
        builder: (BuildContext context, QuizExeState state) {
          if (state is QuizExeDisplayCardState) {
            final quizCard = state.quizCardItem;
            return QuizDisplayWidget(
              quizCardItem: quizCard,
              isProcessing: state.isProcessing,
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
        listener: (BuildContext context, QuizExeState state) {
          if (state is QuizExeErrorState) {
            snackBar(
              context,
              message: state.message,
            );
          }
        },
      ),
    );
  }
}
