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
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_content_bottom_sheet.dart';
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
      backgroundColor: AppColors.backgroundSecondary,
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
    isScrollControlled: true,
    builder: (sheetContext) => AppContentBottomSheet(
      title: localize(context).importExportSelectDeckTitle,
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: decks.map((deck) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
    isScrollControlled: true,
    builder: (sheetContext) => AppContentBottomSheet(
      title: localize(context).importExportImportSourceTitle,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      ),
    ),
  );
}

void _showJsonFormatSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AppContentBottomSheet(
      title: localize(context).importExportJsonFormatTitle,
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _JsonExampleCard(
              title: localize(context).importExportDecksFormatTitle,
              json: '{\n'
                  '  "decks": [\n'
                  '    {\n'
                  '      "title": "My Deck",\n'
                  '      "cards": [\n'
                  '        {\n'
                  '          "question": "..."\n'
                  '          "answer": "..."\n'
                  '        }\n'
                  '      ]\n'
                  '    }\n'
                  '  ]\n'
                  '}',
              onCopied: () {
                Navigator.of(context).pop();
                snackBar(context,
                    message:
                        localize(context).importExportCopiedToClipboard);
              },
            ),
            const SizedBox(height: 24),
            _JsonExampleCard(
              title: localize(context).importExportCardsFormatTitle,
              json: '{\n'
                  '  "cards": [\n'
                  '    {\n'
                  '      "question": "..."\n'
                  '      "answer": "..."\n'
                  '    }\n'
                  '  ]\n'
                  '}',
              onCopied: () {
                Navigator.of(context).pop();
                snackBar(context,
                    message:
                        localize(context).importExportCopiedToClipboard);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showExportSelectionSheet(
  BuildContext context,
  ImportExportCubit cubit,
  ImportExportDataState initialState,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) =>
        BlocBuilder<ImportExportCubit, ImportExportState>(
      bloc: cubit,
      buildWhen: (_, next) => next is ImportExportDataState,
      builder: (_, state) {
        final dataState =
            state is ImportExportDataState ? state : initialState;
        return AppContentBottomSheet(
          title: localize(context).importExportSelectDecksToExport,
          content: ListView(
            shrinkWrap: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (dataState.allSelected) {
                        cubit.deselectAllDecks();
                      } else {
                        cubit.selectAllDecks();
                      }
                    },
                    child: Text(
                      dataState.allSelected
                          ? localize(context).importExportDeselectAll
                          : localize(context).importExportSelectAll,
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dataState.decks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                ...dataState.decks.map((deck) {
                  final isSelected =
                      dataState.selectedDeckIds.contains(deck.id);
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
                      .importExportExportSelectedButton(
                          dataState.selectedDeckIds.length),
                  leadingIcon: Icons.upload_rounded,
                  onPressed: dataState.hasSelection
                      ? () {
                          Navigator.of(sheetContext).pop();
                          cubit.exportSelectedDecks();
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      },
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
        const SizedBox(height: 8),
        _ImportCard(cubit: cubit),
        const SizedBox(height: 32),
        _ExportCard(state: state, cubit: cubit),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ImportCard extends StatelessWidget {
  const _ImportCard({required this.cubit});

  final ImportExportCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.download_rounded,
            title: localize(context).importExportImportTitle,
            subtitle: localize(context).importExportImportSubtitle,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: localize(context).importExportImportDecksButton,
              leadingIcon: Icons.layers_rounded,
              onPressed: () => _showImportSourceSheet(
                context,
                onFile: () => cubit.importDecksFromFile(),
                onClipboard: () => cubit.importDecksFromClipboard(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              text: localize(context).importExportImportCardsButton,
              leadingIcon: Icons.style_rounded,
              onPressed: () => _showImportSourceSheet(
                context,
                onFile: () => cubit.importCardsFromFile(),
                onClipboard: () => cubit.importCardsFromClipboard(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showJsonFormatSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primary500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localize(context).importExportViewJsonFormat,
                    style: AppTypography.buttonSmall.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.state,
    required this.cubit,
  });

  final ImportExportDataState state;
  final ImportExportCubit cubit;

  @override
  Widget build(BuildContext context) {
    final selectionText = state.allSelected || !state.hasSelection
        ? localize(context).importExportAllDecks
        : '${state.selectedDeckIds.length}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _CardHeader(
            icon: Icons.upload_rounded,
            title: localize(context).importExportExportTitle,
            subtitle: localize(context).importExportExportDescription,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              localize(context).importExportSelectDecksToExport,
              style: AppTypography.h4.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              if (!state.hasSelection) {
                cubit.selectAllDecks();
              }
              _showExportSelectionSheet(context, cubit, state);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grayscale100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectionText,
                    style: AppTypography.mainText.copyWith(
                      color: state.hasSelection
                          ? AppColors.grayscale600
                          : AppColors.grayscale300,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.grayscale600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.yellow100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.yellow500,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JsonExampleCard extends StatelessWidget {
  const _JsonExampleCard({
    required this.title,
    required this.json,
    this.onCopied,
  });

  final String title;
  final String json;
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.grayscaleWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                json,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.grayscale500,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: json));
                  onCopied?.call();
                },
                child: const Icon(
                  Icons.copy,
                  size: 24,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
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