import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/ai_generate/cubit/ai_generate_cubit.dart';
import 'package:poc_ai_quiz/view/ai_generate/display/editable_card_tile.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/paywall_bottom_sheet.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_simple_header.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_form.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';

class AiGenerateWidget extends HookWidget {
  const AiGenerateWidget({required this.deckItem, super.key});

  final DeckItem deckItem;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final cubit = useMemoized(
      () => AiGenerateCubit(
        aiGenService: getIt<AiGenService>(),
        deckItem: deckItem,
        quizCardRepository: getIt<QuizCardRepository>(),
        quizCardPremiumManager: getIt<QuizCardPremiumManager>(),
      ),
    );
    useEffect(() => cubit.close, [cubit]);

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
      promptController.clear();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocListener<AiGenerateCubit, AiGenerateState>(
          bloc: cubit,
          listenWhen: (prev, next) => next is ListenerState,
          listener: (context, state) {
            if (state is AiGenerateSavedState) {
              context.pop();
            } else if (state is AiGenerateSaveBlockedState) {
              showPaywallBottomSheet(
                context,
                limitMessage: l10n.quizCardListPremiumCardLimitMessage,
                feature: InAppPurchaseFeature.unlimitedDecksCards,
              );
            } else if (state is AiGenerateErrorState) {
              snackBar(context, message: state.message, isError: true);
            }
          },
          child: Column(
            children: [
              AppSimpleHeader(
                title: l10n.aiGenerateTitle,
                onBackPressed: () => context.pop(),
              ),
              Expanded(
                child: BlocBuilder<AiGenerateCubit, AiGenerateState>(
                  bloc: cubit,
                  buildWhen: (prev, next) => next is BuilderState,
                  builder: (context, state) => _Body(cubit: cubit, state: state),
                ),
              ),
              BlocBuilder<AiGenerateCubit, AiGenerateState>(
                bloc: cubit,
                buildWhen: (prev, next) => next is BuilderState,
                builder: (context, state) {
                  final isGenerating = state is AiGenerateGeneratingState;
                  final hasContent = state is AiGenerateContentState &&
                      state.cards.isNotEmpty;
                  return _Composer(
                    controller: promptController,
                    hint: cubit.hasContent
                        ? l10n.aiGenerateRefineHint
                        : l10n.aiGeneratePromptHint,
                    canSend: canSend && !isGenerating,
                    showSave: hasContent && !isGenerating,
                    onSend: submitPrompt,
                    onSave: cubit.save,
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

  final AiGenerateCubit cubit;
  final AiGenerateState state;

  @override
  Widget build(BuildContext context) {
    if (state is AiGenerateInitialState) {
      return const _InitialHint();
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

  final AiGenerateCubit cubit;
  final List<AiGenerateCard> cards;

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
          index: index,
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

class _InitialHint extends StatelessWidget {
  const _InitialHint();

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 56, color: AppColors.primary500),
          const SizedBox(height: 16),
          Text(
            l10n.aiGenerateInitialTitle,
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiGenerateInitialHint,
            textAlign: TextAlign.center,
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  const _AddCardButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return AppButton.secondary(
      text: l10n.aiGenerateAddCardLabel,
      leadingIcon: const Icon(Icons.add, size: 20),
      onPressed: onPressed,
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.canSend,
    required this.showSave,
    required this.onSend,
    required this.onSave,
  });

  final TextEditingController controller;
  final String hint;
  final bool canSend;
  final bool showSave;
  final VoidCallback onSend;
  final VoidCallback onSave;

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
        children: [
          if (showSave) ...[
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                text: l10n.aiGenerateSaveButton,
                onPressed: onSave,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
