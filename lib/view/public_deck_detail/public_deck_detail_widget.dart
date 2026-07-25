import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_summary.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/public_decks_repository.dart';
import 'package:poc_ai_quiz/domain/sync/sync_scheduler.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/public_deck_detail/cubit/public_deck_detail_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/display/quiz_card_list_display_widget.dart';
import 'package:quizzy_design/quizzy_design.dart';

class PublicDeckDetailWidget extends HookWidget {
  const PublicDeckDetailWidget({
    required this.deckSummary,
    super.key,
  });

  final PublicDeckSummary deckSummary;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => PublicDeckDetailCubit(
        deckId: deckSummary.id,
        publicDecksRepository: getIt<PublicDecksRepository>(),
        syncScheduler: getIt<SyncScheduler>(),
        logger: Logger.withTag('PublicDeckDetailCubit'),
      ),
    );

    useEffect(() {
      cubit.loadDeck();
      return cubit.close;
    }, [cubit]);

    final l10n = localize(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: BlocConsumer<PublicDeckDetailCubit, PublicDeckDetailState>(
          bloc: cubit,
          buildWhen: (prevState, nextState) => nextState is BuilderState,
          listenWhen: (prevState, nextState) => nextState is ListenerState,
          listener: (context, state) {
            if (state is PublicDeckDetailCopySuccessState) {
              snackBar(context, message: l10n.publicDeckCopySuccessMessage);
              context.go(HomeRoute().path);
            } else if (state is PublicDeckDetailCopyErrorState) {
              snackBar(
                context,
                message: l10n.publicDeckCopyErrorMessage,
                isError: true,
              );
            }
          },
          builder: (context, state) {
            final isCopying =
                state is PublicDeckDetailDataState && state.isCopying;
            final canCopy =
                state is PublicDeckDetailDataState && !state.isCopying;
            return Column(
              children: [
                AppSimpleHeader(
                  title: deckSummary.title,
                  onBackPressed: () => context.pop(),
                  trailing: _CopyDeckButton(
                    isLoading: isCopying,
                    onPressed: canCopy ? cubit.copyDeck : null,
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is PublicDeckDetailDataState) {
                        final cards = List.of(state.deckDetail.cards)
                          ..sort((a, b) => a.position.compareTo(b.position));
                        if (cards.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.publicDecksEmptyState,
                              style: AppTypography.h4.copyWith(
                                color: AppColors.grayscale500,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: cards.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return QuizCardTile(
                              question: card.question,
                              answer: card.answer,
                              showCheckbox: false,
                            );
                          },
                        );
                      }
                      if (state is PublicDeckDetailErrorState) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              l10n.publicDeckDetailErrorMessage,
                              textAlign: TextAlign.center,
                              style: AppTypography.h4.copyWith(
                                color: AppColors.grayscale500,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Center(child: SimpleLoadingWidget());
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CopyDeckButton extends StatelessWidget {
  const _CopyDeckButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        elevation: 0,
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.transparent;
          }
          return AppColors.grayscaleWhite;
        }),
      ),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.grayscale600,
              ),
            )
          : SvgPicture.asset(
              'assets/icons/copy.svg',
              width: 32 * 0.6,
              height: 32 * 0.6,
            ),
    );
  }
}
