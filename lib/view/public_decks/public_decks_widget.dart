import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_category.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_summary.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/public_decks_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_item_widget.dart';
import 'package:poc_ai_quiz/view/public_decks/cubit/public_decks_cubit.dart';
import 'package:quizzy_design/quizzy_design.dart';

class PublicDecksWidget extends HookWidget {
  const PublicDecksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => PublicDecksCubit(
        publicDecksRepository: getIt<PublicDecksRepository>(),
        logger: Logger.withTag('PublicDecksCubit'),
      ),
    );
    final searchController = useTextEditingController();

    useEffect(() {
      cubit.loadInitial();
      return cubit.close;
    }, [cubit]);

    void openDeck(PublicDeckSummary deck) {
      context.push(PublicDeckDetailRoute().path, extra: deck);
    }

    final l10n = localize(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: l10n.publicDecksTitle,
              onBackPressed: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppTextField(
                controller: searchController,
                hint: l10n.publicDecksSearchHint,
                onChanged: cubit.onSearchChanged,
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child: BlocConsumer<PublicDecksCubit, PublicDecksState>(
                bloc: cubit,
                buildWhen: (prevState, nextState) => nextState is BuilderState,
                builder: (context, state) {
                  if (state is PublicDecksDataState) {
                    return Column(
                      children: [
                        _CategoryFilterRow(
                          categories: state.categories,
                          selectedCategory: state.selectedCategory,
                          onCategorySelected: cubit.selectCategory,
                        ),
                        Expanded(
                          child: state.decks.isEmpty
                              ? _EmptyPublicDecksWidget(message: l10n.publicDecksEmptyState)
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  itemCount: state.decks.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final deck = state.decks[index];
                                    return DeckListItemWidget(
                                      title: deck.title,
                                      onTap: () => openDeck(deck),
                                      trailing: Text(
                                        '${deck.cardCount}',
                                        style: AppTypography.secondaryText
                                            .copyWith(
                                          color: AppColors.grayscale500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: SimpleLoadingWidget());
                },
                listenWhen: (prevState, nextState) =>
                    nextState is ListenerState,
                listener: (context, state) {
                  if (state is PublicDecksErrorState) {
                    snackBar(
                      context,
                      message: l10n.publicDecksErrorMessage,
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

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<PublicCategory> categories;
  final PublicCategory? selectedCategory;
  final ValueChanged<PublicCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = localize(context);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: l10n.publicDecksAllCategoriesLabel,
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            isSelected: selectedCategory?.id == category.id,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.grayscale300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.buttonSmall.copyWith(
            color: isSelected ? AppColors.grayscaleWhite : AppColors.grayscale600,
          ),
        ),
      ),
    );
  }
}

class _EmptyPublicDecksWidget extends StatelessWidget {
  const _EmptyPublicDecksWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.h4.copyWith(color: AppColors.grayscale500),
        ),
      ),
    );
  }
}
