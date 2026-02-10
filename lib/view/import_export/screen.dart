import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_cubit.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_state.dart';
import 'package:poc_ai_quiz/view/widgets/app_bottom_sheet.dart';
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
                    final exception = state.exception;
                    if (exception is ImportLimitExceededException) {
                      final type = exception.type;
                      final limit = exception.limit;
                      final typeName = type == ImportExportType.card
                          ? localize(context).card
                          : localize(context).deck;
                      snackBar(
                        context,
                        message: localize(context).importLimitExceeded(
                          limit,
                          typeName,
                        ),
                        isError: true,
                      );
                    } else {
                      snackBar(context,
                          message: localize(context).importExportError,
                          isError: true);
                    }
                  }
                  if (state is ImportExportImportSuccessState) {
                    snackBar(
                      context,
                      message: localize(context)
                          .importExportImportDecksSuccess(state.deckCount),
                    );
                  }
                  if (state is ImportExportImportCardsSuccessState) {
                    snackBar(
                      context,
                      message: localize(context)
                          .importExportImportCardsSuccess(state.cardCount),
                    );
                  }
                  if (state is ImportExportSelectDeckState) {
                    _showDeckPickerSheet(
                      context,
                      cubit,
                      state.decks,
                      fromClipboard: state.fromClipboard,
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

void _showDeckPickerSheet(
  BuildContext context,
  ImportExportCubit cubit,
  List<DeckItem> decks, {
  bool fromClipboard = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AppBottomSheet.neutral(
      title: Text(
        localize(context).importExportSelectDeckTitle,
        style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
      ),
      content: Column(
        children: decks.map((deck) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.of(sheetContext).pop();
                if (fromClipboard) {
                  cubit.confirmImportCardsFromClipboard(deck.id);
                } else {
                  cubit.confirmImportCards(deck.id);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grayscaleWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grayscale200),
                ),
                child: Text(
                  deck.title,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.grayscale600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      button: AppButton.secondary(
        text: localize(context).importExportCancelButton,
        onPressed: () => Navigator.of(sheetContext).pop(),
      ),
    ),
  );
}

void _showImportSourceSheet(
  BuildContext context, {
  required VoidCallback onFile,
  required VoidCallback onClipboard,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AppBottomSheet.neutral(
      title: Text(
        localize(context).importExportImportSourceTitle,
        style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
      ),
      content: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: localize(context).importExportFromFile,
              leadingIcon: Icons.file_open,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                onFile();
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: localize(context).importExportFromClipboard,
              leadingIcon: Icons.paste,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                onClipboard();
              },
            ),
          ),
        ],
      ),
      button: AppButton.secondary(
        text: localize(context).importExportCancelButton,
        onPressed: () => Navigator.of(sheetContext).pop(),
      ),
    ),
  );
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // -- Import Section --
        const SizedBox(height: 8),
        _SectionHeader(
          icon: Icons.file_download,
          title: localize(context).importExportImportTitle,
        ),
        const SizedBox(height: 12),
        Text(
          localize(context).importExportImportDescription,
          style: AppTypography.secondaryText.copyWith(
            color: AppColors.grayscale500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _JsonExampleCard(
                title: localize(context).importExportDecksButton,
                json: '{\n'
                    '  "decks": [\n'
                    '    {\n'
                    '      "title": "My Deck",\n'
                    '      "cards": [\n'
                    '        {\n'
                    '          "question": "...",\n'
                    '          "answer": "..."\n'
                    '        }\n'
                    '      ]\n'
                    '    }\n'
                    '  ]\n'
                    '}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _JsonExampleCard(
                title: localize(context).importExportCardsButton,
                json: '{\n'
                    '  "cards": [\n'
                    '    {\n'
                    '      "question": "...",\n'
                    '      "answer": "..."\n'
                    '    }\n'
                    '  ]\n'
                    '}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                text: localize(context).importExportDecksButton,
                leadingIcon: Icons.file_download,
                onPressed: () => _showImportSourceSheet(
                  context,
                  onFile: () => cubit.importDecksFromFile(),
                  onClipboard: () => cubit.importDecksFromClipboard(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton.secondary(
                text: localize(context).importExportCardsButton,
                leadingIcon: Icons.file_download,
                onPressed: () => _showImportSourceSheet(
                  context,
                  onFile: () => cubit.importCardsFromFile(),
                  onClipboard: () => cubit.importCardsFromClipboard(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // -- Export Section --
        _SectionHeader(
          icon: Icons.file_upload,
          title: localize(context).importExportExportTitle,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              localize(context).importExportSelectDecksToExport,
              style: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale500,
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
                state.allSelected
                    ? localize(context).importExportDeselectAll
                    : localize(context).importExportSelectAll,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.decks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                localize(context).importExportNoDecksAvailable,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale400,
                ),
              ),
            ),
          )
        else
          ...state.decks.map((deck) {
            final isSelected = state.selectedDeckIds.contains(deck.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DeckSelectionTile(
                title: deck.title,
                isSelected: isSelected,
                onTap: () => cubit.toggleDeckSelection(deck.id),
              ),
            );
          }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            text: localize(context)
                .importExportExportSelectedButton(state.selectedDeckIds.length),
            leadingIcon: Icons.file_upload,
            onPressed:
                state.hasSelection ? () => cubit.exportSelectedDecks() : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary500, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.grayscale600,
          ),
        ),
      ],
    );
  }
}

class _JsonExampleCard extends StatelessWidget {
  const _JsonExampleCard({
    required this.title,
    required this.json,
  });

  final String title;
  final String json;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayscale100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grayscale200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: json));
                  snackBar(context,
                      message: localize(context).importExportCopiedToClipboard);
                },
                child: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.grayscale400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            json,
            style: AppTypography.secondaryText.copyWith(
              color: AppColors.grayscale600,
              fontFamily: 'monospace',
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
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
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary500 : AppColors.grayscale400,
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
