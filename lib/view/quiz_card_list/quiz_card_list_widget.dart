import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_exe_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/cubit/quiz_card_list_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/display/quiz_card_list_display_widget.dart';
import 'package:poc_ai_quiz/view/widgets/app_back_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';

class QuizCardListWidget extends HookWidget {
  const QuizCardListWidget({
    required this.deckItem,
    super.key,
  });

  final DeckItem deckItem;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => QuizCardListCubit(
        deckItem: deckItem,
        quizCardRepository: getIt<QuizCardRepository>(),
        quizCardPremiumManager: getIt<QuizCardPremiumManager>(),
        quizCardExeValidator: getIt<QuizCardExeValidator>(),
      ),
    );

    useEffect(
      () {
        cubit.fetchQuizCardListRequest();
        return cubit.close;
      },
      [cubit],
    );

    void addCardRequest() {
      context.push(CreateCardRoute().path).then((cardRequest) {
        if (cardRequest is QuizCardRequestItem) {
          cubit.createQuizCardItem(cardRequest);
        }
      });
    }

    void launchConfirmDeleteRequest(QuizCardItem card) {
      alert(
        context,
        content: Text(
          localize(context).quizCardListDeleteCardConfirmation,
        ),
      ).then(
        (value) {
          if (value ?? false) {
            cubit.deleteCard(card);
          }
        },
      );
    }

    void launchEditCardRequest(QuizCardItem card) {
      context.push(CreateCardRoute().path, extra: card).then((cardRequest) {
        if (cardRequest is QuizCardRequestItem) {
          cubit.editQuizCard(card, cardRequest);
        }
      });
    }

    void showCreateCardPremiumError() {
      alert(
        context,
        content: Text(
          localize(context).quizCardListPremiumCardLimitMessage,
        ),
        secondary: const SizedBox.shrink(),
      ).then(
        (value) {
          if (value ?? false) {
            // TODO Navigate to purchase screen
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: deckItem.title,
              onBackPressed: () => context.pop(),
            ),
            Expanded(
              child: BlocConsumer<QuizCardListCubit, QuizCardListState>(
                bloc: cubit,
                buildWhen: (oldState, newState) {
                  return newState is BuilderState;
                },
                builder: (context, state) {
                  if (state is QuizCardListDataState) {
                    return QuizCardListDisplayWidget(
                      quizCarList: state.quizCarList,
                      onQuizCardEditRequest: launchEditCardRequest,
                      onQuizCardRemoveRequest: launchConfirmDeleteRequest,
                      onAddCardRequest: () => cubit.addCardRequest(),
                    );
                  }
                  if (state is QuizCardListLoadingState) {
                    return const SimpleLoadingWidget();
                  }
                  throw ArgumentError('Wrong state');
                },
                listenWhen: (oldState, newState) {
                  return newState is ListenerState;
                },
                listener: (context, state) {
                  if (state is QuizCardLaunchState) {
                    context.push(
                      QuizExeRoute().path,
                      extra: {
                        QuizExeRoute.quizCardsKey: state.quizCarList,
                        QuizExeRoute.isQuickPlayKey: state.isQuickPlay,
                      },
                    );
                  }
                  if (state is RequestCreateQuizCardState) {
                    if (state.canCreateCard) {
                      addCardRequest();
                    } else {
                      showCreateCardPremiumError();
                    }
                  }
                  if (state is QuizCardListErrorState) {
                    snackBar(
                      context,
                      message: state.message,
                    );
                  }
                },
              ),
            ),
            _BottomButtons(
              onQuickPlayPressed: () =>
                  cubit.launchQuizRequest(isQuickPlay: true),
              onPlayDeckPressed: () => cubit.launchQuizRequest(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.onBackPressed,
  });

  final String title;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          AppBackButton(onPressed: onBackPressed),
          Expanded(
            child: Text(
              title,
              style: AppTypography.h2.copyWith(
                color: AppColors.grayscale600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    this.onQuickPlayPressed,
    this.onPlayDeckPressed,
  });

  final VoidCallback? onQuickPlayPressed;
  final VoidCallback? onPlayDeckPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            text: l10n.quizCardListQuickPlayButton,
            leadingIcon: Icons.bolt,
            onPressed: onQuickPlayPressed,
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            text: l10n.quizCardListPlayDeckButton,
            leadingIcon: Icons.play_arrow,
            onPressed: onPlayDeckPressed,
          ),
        ],
      ),
    );
  }
}
