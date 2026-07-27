import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_exe_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/paywall_bottom_sheet.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/cubit/quiz_card_list_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/display/quiz_card_list_display_widget.dart';
import 'package:solar_icons/solar_icons.dart';

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
        deckRepository: getIt<DeckRepository>(),
        quizCardPremiumManager: getIt<QuizCardPremiumManager>(),
        quizCardExeValidator: getIt<QuizCardExeValidator>(),
        analyticsService: getIt<AnalyticsService>(),
        isSubscriptionOnly: getIt<AppConfig>().isSubscriptionOnly,
      ),
    );

    useEffect(
      () {
        cubit.watchCards();
        cubit.watchDeck();
        return cubit.close;
      },
      [cubit],
    );

    final shuffleValue = useState(false);
    final switchSidesValue = useState(false);
    final isSelectionModeActive = useState(false);

    void addCardRequest() {
      context.push(CreateCardRoute().path).then((cardRequest) {
        if (cardRequest is QuizCardRequestItem) {
          cubit.createQuizCardItem(cardRequest);
        }
      });
    }

    void launchDeckEdit() {
      context.push(DeckEditRoute().path, extra: deckItem);
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

    Future<void> showCreateCardPremiumError() async {
      final purchased = await showPaywallBottomSheet(
        context,
        limitMessage: localize(context).quizCardListPremiumCardLimitMessage,
        feature: cubit.unlockFeature,
        trigger: 'card_limit',
        limitType: 'card',
      );
      if (purchased == true && context.mounted) {
        cubit.addCardRequest();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: deckItem.title,
              onBackPressed: () => context.pop(),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCircleIconButton(
                    icon: SolarIconsOutline.addSquare,
                    onPressed: () => launchDeckEdit(),
                  ),
                  const SizedBox(width: 8),
                  AppCircleIconButton(
                    icon: SolarIconsOutline.magicStick_3,
                    onPressed: () => cubit.addCardRequest(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<QuizCardListCubit, QuizCardListState>(
                bloc: cubit,
                buildWhen: (oldState, newState) {
                  return newState is BuilderState;
                },
                builder: (context, state) {
                  if (state is QuizCardListDataState) {
                    return Column(
                      children: [
                        Expanded(
                          child: QuizCardListDisplayWidget(
                            quizCarList: state.quizCarList,
                            deckStats: state.deckStats,
                            selectedCardIds: state.selectedCardIds,
                            isSelectionModeActive: isSelectionModeActive.value,
                            onCardSelectionToggle: (cardId) =>
                                cubit.toggleCardSelection(cardId),
                            onQuizCardEditRequest: launchEditCardRequest,
                            onQuizCardRemoveRequest: launchConfirmDeleteRequest,
                            onAddCardRequest: () => cubit.addCardRequest(),
                          ),
                        ),
                        if (state.quizCarList.isNotEmpty)
                          _BottomButtons(
                            hasSelection: state.hasSelection,
                            selectedCount: state.selectedCount,
                            allSelected: state.allSelected,
                            isSelectionModeActive: isSelectionModeActive.value,
                            onEnterSelectionMode: (isModeOn) {
                              isSelectionModeActive.value = isModeOn;
                              if (!isModeOn) {
                                cubit.clearSelection();
                              }
                            },
                            onSelectAllPressed: () => cubit.selectAllCards(),
                            onClearSelectionPressed: () {
                              cubit.clearSelection();
                            },
                            onQuickPlayPressed: () => cubit.launchQuizRequest(
                              isQuickPlay: true,
                              isShuffle: shuffleValue.value,
                              switchSides: switchSidesValue.value,
                            ),
                            onPlayDeckPressed: () => cubit.launchQuizRequest(
                              isShuffle: shuffleValue.value,
                              switchSides: switchSidesValue.value,
                            ),
                            onShufflePressed: (isShuffle) =>
                                shuffleValue.value = isShuffle,
                            onSwitchSidesPressed: (isSwitched) =>
                                switchSidesValue.value = isSwitched,
                            shuffleEnabled: shuffleValue.value,
                            switchSides: switchSidesValue.value,
                          ),
                      ],
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
                      isError: true,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    this.hasSelection = false,
    this.selectedCount = 0,
    this.allSelected = false,
    this.isSelectionModeActive = false,
    this.onEnterSelectionMode,
    this.onSelectAllPressed,
    this.onClearSelectionPressed,
    this.onQuickPlayPressed,
    this.onPlayDeckPressed,
    this.onShufflePressed,
    this.onSwitchSidesPressed,
    this.shuffleEnabled = false,
    this.switchSides = false,
  });

  final bool hasSelection;
  final int selectedCount;
  final bool allSelected;
  final bool isSelectionModeActive;
  final ValueChanged<bool>? onEnterSelectionMode;
  final VoidCallback? onSelectAllPressed;
  final VoidCallback? onClearSelectionPressed;
  final VoidCallback? onQuickPlayPressed;
  final VoidCallback? onPlayDeckPressed;
  final ValueChanged<bool>? onShufflePressed;
  final bool shuffleEnabled;
  final ValueChanged<bool>? onSwitchSidesPressed;
  final bool switchSides;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final playButtonText = hasSelection
        ? l10n.quizCardListPlaySelectedButton(selectedCount)
        : l10n.quizCardListPlayDeckButton;

    final quizPlayButtonText = hasSelection
        ? l10n.quizCardListQuickPlaySelectedButton(selectedCount)
        : l10n.quizCardListQuickPlayButton;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SelectButton(
                  isSelectionModeActive: isSelectionModeActive,
                  hasSelection: hasSelection,
                  allSelected: allSelected,
                  onEnterSelectionMode: onEnterSelectionMode,
                  onSelectAllPressed: onSelectAllPressed,
                  onClearSelectionPressed: onClearSelectionPressed,
                ),
                TextButton(
                  onPressed: () {
                    onSwitchSidesPressed?.call(!switchSides);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    switchSides
                        ? l10n.quizCardListSideSwitched
                        : l10n.quizCardListSidesNotSwitched,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onShufflePressed?.call(!shuffleEnabled);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    shuffleEnabled
                        ? l10n.quizCardListShuffleCards
                        : l10n.quizCardListCardsInOrder,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppButton.primary(
            text: quizPlayButtonText,
            leadingIcon: const Icon(Icons.bolt, size: 20),
            onPressed: onQuickPlayPressed,
          ),
          const SizedBox(height: 16),
          AppButton.secondary(
            text: playButtonText,
            leadingIcon: const Icon(Icons.play_arrow, size: 20),
            onPressed: onPlayDeckPressed,
          ),
        ],
      ),
    );
  }
}

class _SelectButton extends StatelessWidget {
  const _SelectButton({
    required this.isSelectionModeActive,
    required this.hasSelection,
    required this.allSelected,
    this.onEnterSelectionMode,
    this.onSelectAllPressed,
    this.onClearSelectionPressed,
  });

  final bool isSelectionModeActive;
  final bool hasSelection;
  final bool allSelected;
  final ValueChanged<bool>? onEnterSelectionMode;
  final VoidCallback? onSelectAllPressed;
  final VoidCallback? onClearSelectionPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);

    // When selection mode is off: show simple "Select" button
    if (!isSelectionModeActive) {
      return TextButton(
        onPressed: () {
          onEnterSelectionMode?.call(true);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n.quizCardListSelect,
          style: AppTypography.h3.copyWith(
            color: AppColors.primary500,
          ),
        ),
      );
    }

    // When selection mode is on: show toggle button + close icon
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            if (allSelected) {
              onClearSelectionPressed?.call();
            } else {
              onSelectAllPressed?.call();
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            allSelected
                ? l10n.quizCardListClearSelection
                : l10n.quizCardListSelectAll,
            style: AppTypography.buttonSmall.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {
            onEnterSelectionMode?.call(false);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(
            Icons.close,
            color: AppColors.primary500,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
