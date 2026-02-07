import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_cubit.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_state.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_simple_header.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';

class ImportExportScreen extends HookWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => ImportExportCubit(
        deckRepository: getIt<DeckRepository>(),
        importExportService: getIt<ImportExportService>(),
      ),
    );

    useEffect(() {
      cubit.loadDecks();
      return cubit.close;
    }, []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: localize(context).settingsImportExportTitle,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocConsumer<ImportExportCubit, ImportExportState>(
                bloc: cubit,
                buildWhen: (_, next) => next is BuilderState,
                listenWhen: (_, next) => next is ListenerState,
                listener: (context, state) {
                  if (state is ImportExportErrorState) {
                    snackBar(context, message: state.message, isError: true);
                  }
                  if (state is ImportExportImportSuccessState) {
                    snackBar(
                      context,
                      message:
                          'Successfully imported ${state.deckCount} deck(s)',
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ImportExportLoadingState) {
                    return const Center(child: SimpleLoadingWidget());
                  }
                  if (state is ImportExportDataState) {
                    return _DataContent(
                      state: state,
                      cubit: cubit,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataContent extends StatelessWidget {
  const _DataContent({
    required this.state,
    required this.cubit,
  });

  final ImportExportDataState state;
  final ImportExportCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Import section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: AppButton.secondary(
              text: 'Import from File',
              leadingIcon: Icons.file_download,
              onPressed: () => cubit.importFromFile(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Export section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Select decks to export',
                style: AppTypography.h4.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (state.allSelected) {
                    cubit.deselectAllDecks();
                  } else {
                    cubit.selectAllDecks();
                  }
                },
                child: Text(
                  state.allSelected ? 'Deselect all' : 'Select all',
                  style: AppTypography.secondaryText.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Deck list
        Expanded(
          child: state.decks.isEmpty
              ? Center(
                  child: Text(
                    'No decks available',
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.grayscale400,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.decks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final deck = state.decks[index];
                    final isSelected =
                        state.selectedDeckIds.contains(deck.id);
                    return _DeckSelectionTile(
                      title: deck.title,
                      isSelected: isSelected,
                      onTap: () => cubit.toggleDeckSelection(deck.id),
                    );
                  },
                ),
        ),
        // Export button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: 'Export Selected (${state.selectedDeckIds.length})',
              leadingIcon: Icons.file_upload,
              onPressed:
                  state.hasSelection ? () => cubit.exportSelectedDecks() : null,
            ),
          ),
        ),
      ],
    );
  }

}

class _DeckSelectionTile extends StatelessWidget {
  const _DeckSelectionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.1)
              : AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.grayscale200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primary500
                  : AppColors.grayscale400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.h4.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}