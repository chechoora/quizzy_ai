import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/quiz/initial_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/display/quiz_display_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/done/quiz_done_widget.dart';
import 'package:poc_ai_quiz/view/quiz_exe/quiz_exe_cubit.dart';

class QuizExeWidget extends HookWidget {
  const QuizExeWidget({
    required this.cards,
    this.isQuickPlay = false,
    super.key,
  });

  final List<QuizCardItem> cards;
  final bool isQuickPlay;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => QuizExeCubit(
        quizService: getIt<QuizService>(),
        quizCardItems: cards,
        quizMatchBuilder: QuizMatchBuilder(),
        settingsService: getIt<SettingsService>(),
        validatorsManager: getIt<ValidatorsManager>(),
        initialAnswerValidator: InitialAnswerValidator(),
        isQuickPlay: isQuickPlay,
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
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocConsumer<QuizExeCubit, QuizExeState>(
          bloc: cubit,
          buildWhen: (previous, current) =>
              current is! QuizExeErrorState && current is! QuizCardResultState,
          builder: (BuildContext context, QuizExeState state) {
            if (state is QuizExeDisplayCardState) {
              final quizCard = state.quizCardItem;
              return QuizDisplayWidget(
                quizCardItem: quizCard,
                isProcessing: state.isProcessing,
                currentIndex: state.currentIndex,
                totalCards: state.totalCards,
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
            if (state is QuizCardResultState) {
              final result = state.answerResult;
              final l10n = localize(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  dismissDirection: DismissDirection.none,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          l10n.quizExeScoreLabel((result.score * 100).toInt())),
                      const SizedBox(height: 4),
                      result.explanation != null
                          ? Text(l10n.quizExeDetailsLabel(result.explanation!))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(days: 365),
                  action: SnackBarAction(
                    label: l10n.quizExeNextCardButton,
                    textColor: Theme.of(context).colorScheme.onError,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      cubit.nextCard();
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
