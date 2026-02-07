import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_state.dart';

final _logger = Logger.withTag('ImportExportCubit');

class ImportExportCubit extends Cubit<ImportExportState> {
  ImportExportCubit({
    required this.deckRepository,
    required this.importExportService,
  }) : super(const ImportExportLoadingState());

  final DeckRepository deckRepository;
  final ImportExportService importExportService;

  final Set<int> _selectedDeckIds = {};

  Future<void> loadDecks() async {
    emit(const ImportExportLoadingState());
    try {
      final decks = await deckRepository.fetchDecks();
      _selectedDeckIds.clear();
      emit(ImportExportDataState(decks: decks, selectedDeckIds: const {}));
    } catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(message: 'Failed to load decks: $e'));
    }
  }

  void toggleDeckSelection(int deckId) {
    if (_selectedDeckIds.contains(deckId)) {
      _selectedDeckIds.remove(deckId);
    } else {
      _selectedDeckIds.add(deckId);
    }
    final currentState = state;
    if (currentState is ImportExportDataState) {
      emit(currentState.copyWith(selectedDeckIds: Set.from(_selectedDeckIds)));
    }
  }

  void selectAllDecks() {
    final currentState = state;
    if (currentState is ImportExportDataState) {
      _selectedDeckIds
        ..clear()
        ..addAll(currentState.decks.map((d) => d.id));
      emit(currentState.copyWith(selectedDeckIds: Set.from(_selectedDeckIds)));
    }
  }

  void deselectAllDecks() {
    _selectedDeckIds.clear();
    final currentState = state;
    if (currentState is ImportExportDataState) {
      emit(currentState.copyWith(selectedDeckIds: const {}));
    }
  }

  Future<void> exportSelectedDecks() async {
    final currentState = state;
    if (currentState is! ImportExportDataState) return;
    if (_selectedDeckIds.isEmpty) return;

    emit(const ImportExportLoadingState());
    try {
      final selectedDecks = currentState.decks
          .where((d) => _selectedDeckIds.contains(d.id))
          .toList();

      await importExportService.exportDecks(selectedDecks);
      emit(ImportExportDataState(
        decks: currentState.decks,
        selectedDeckIds: Set.from(_selectedDeckIds),
      ));
    } catch (e, stackTrace) {
      _logger.e('Failed to export decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(message: 'Failed to export: $e'));
      loadDecks();
    }
  }

  Future<void> importFromFile() async {
    emit(const ImportExportLoadingState());
    try {
      final importedCount = await importExportService.importDecksFromFile();
      if (importedCount == null) {
        // User cancelled file picker
        await loadDecks();
        return;
      }
      emit(ImportExportImportSuccessState(deckCount: importedCount));
      await loadDecks();
    } catch (e, stackTrace) {
      _logger.e('Failed to import', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(message: 'Failed to import: $e'));
      loadDecks();
    }
  }
}
