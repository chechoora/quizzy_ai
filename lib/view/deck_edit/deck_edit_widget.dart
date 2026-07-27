import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/deck_edit/cubit/cubit.dart';
import 'package:poc_ai_quiz/view/deck_edit/display/editable_card_tile.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/paywall_bottom_sheet.dart';
import 'package:solar_icons/solar_icons.dart';

class DeckEditWidget extends HookWidget {
  const DeckEditWidget({required this.deckItem, super.key});

  final DeckItem deckItem;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final cubit = useMemoized(
      () => DeckEditCubit(
        aiGenService: getIt<AiGenService>(),
        deckItem: deckItem,
        quizCardRepository: getIt<QuizCardRepository>(),
        inAppPurchaseService: getIt<InAppPurchaseService>(),
        analyticsService: getIt<AnalyticsService>(),
        isSubscriptionOnly: getIt<AppConfig>().isSubscriptionOnly,
      ),
    );
    useEffect(() {
      cubit.init();
      return cubit.close;
    }, [cubit]);

    final promptController = useTextEditingController();
    final canSend = useListenableSelector(
      promptController,
      () => promptController.text.trim().isNotEmpty,
    );

    void submitPrompt() {
      final prompt = promptController.text.trim();
      if (prompt.isEmpty) return;
      FocusScope.of(context).unfocus();
      if (cubit.hasContent) {
        cubit.refine(prompt);
      } else {
        cubit.generate(prompt);
      }
    }

    Future<void> unlockAi() async {
      final purchased = await showPaywallBottomSheet(
        context,
        limitMessage: l10n.aiGenerateUnlockMessage,
        feature: cubit.unlockFeature,
        trigger: 'ai_composer_unlock',
      );
      if (purchased == true && context.mounted) {
        cubit.onAiUnlocked();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocListener<DeckEditCubit, AiGenerateState>(
          bloc: cubit,
          listenWhen: (prev, next) => next is ListenerState,
          listener: (context, state) {
            if (state is AiGenerateSavedState) {
              context.pop();
            } else if (state is AiGenerateErrorState) {
              snackBar(context, message: state.message, isError: true);
            } else if (state is AiGenerateSuccessState) {
              promptController.clear();
            }
          },
          child: Column(
            children: [
              AppSimpleHeader(
                title: 'Edit ${deckItem.title}',
                onBackPressed: () => context.pop(),
                trailing: BlocBuilder<DeckEditCubit, AiGenerateState>(
                  bloc: cubit,
                  buildWhen: (prev, next) => next is BuilderState,
                  builder: (context, state) {
                    return AppCircleIconButton(
                      icon: SolarIconsOutline.checkCircle,
                      onPressed: cubit.save,
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<DeckEditCubit, AiGenerateState>(
                  bloc: cubit,
                  buildWhen: (prev, next) => next is BuilderState,
                  builder: (context, state) =>
                      _Body(cubit: cubit, state: state),
                ),
              ),
              BlocBuilder<DeckEditCubit, AiGenerateState>(
                bloc: cubit,
                buildWhen: (prev, next) => next is BuilderState,
                builder: (context, state) {
                  final isGenerating = state is AiGenerateGeneratingState;
                  if (!cubit.isPremium) {
                    return _FreeBottomBar(onUnlock: unlockAi);
                  }
                  return _Composer(
                    controller: promptController,
                    hint: cubit.hasContent
                        ? l10n.aiGenerateRefineHint
                        : l10n.aiGeneratePromptHint,
                    canSend: canSend && !isGenerating,
                    onSend: submitPrompt,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.cubit, required this.state});

  final DeckEditCubit cubit;
  final AiGenerateState state;

  @override
  Widget build(BuildContext context) {
    if (state is AiGenerateInitialState) {
      return const SimpleLoadingWidget();
    }
    if (state is AiGenerateGeneratingState) {
      final cards = (state as AiGenerateGeneratingState).cards;
      if (cards.isEmpty) {
        return const SimpleLoadingWidget();
      }
      return Stack(
        children: [
          AbsorbPointer(
            child: Opacity(
              opacity: 0.5,
              child: _CardsList(cubit: cubit, cards: cards),
            ),
          ),
          const Positioned.fill(child: SimpleLoadingWidget()),
        ],
      );
    }
    final content = state as AiGenerateContentState;
    return _CardsList(
      cubit: cubit,
      cards: content.cards,
    );
  }
}

class _CardsList extends StatelessWidget {
  const _CardsList({
    required this.cubit,
    required this.cards,
  });

  final DeckEditCubit cubit;
  final List<EditCard> cards;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: cards.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == cards.length) {
          return _AddCardButton(onPressed: cubit.addCard);
        }
        final card = cards[index];
        return EditableCardTile(
          key: ValueKey(card.localId),
          card: card,
          onQuestionChanged: (value) =>
              cubit.updateCard(card.localId, question: value),
          onAnswerChanged: (value) =>
              cubit.updateCard(card.localId, answer: value),
          onDelete: () => cubit.deleteCard(card.localId),
        );
      },
    );
  }
}

class _AddCardButton extends StatelessWidget {
  const _AddCardButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return AppAddCardTile(
      title: l10n.aiGenerateAddCardLabel,
      onPressed: onPressed,
    );
  }
}

class _FreeBottomBar extends StatelessWidget {
  const _FreeBottomBar({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 18, color: AppColors.primary500),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.aiGenerateUnlockTitle,
                  style: AppTypography.secondaryText.copyWith(
                    color: AppColors.grayscale500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppButton.secondary(
            text: l10n.aiGenerateUnlockButton,
            leadingIcon: const Icon(Icons.lock_open, size: 20),
            onPressed: onUnlock,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppTextForm(
                  controller: controller,
                  hint: hint,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(enabled: canSend, onPressed: onSend),
            ],
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.primary500 : AppColors.grayscale200,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.arrow_upward,
            color: enabled ? AppColors.grayscaleWhite : AppColors.grayscale400,
          ),
        ),
      ),
    );
  }
}
