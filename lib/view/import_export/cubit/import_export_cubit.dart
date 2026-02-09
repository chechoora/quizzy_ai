import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/import_export/exception.dart';
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

  final List<DeckItem> _decks = [];
  final Set<int> _selectedDeckIds = {};

  Future<void> loadDecks() async {
    emit(const ImportExportLoadingState());
    try {
      _decks
        ..clear()
        ..addAll(await deckRepository.fetchDecks());
      _selectedDeckIds.clear();
      emit(ImportExportDataState(decks: _decks, selectedDeckIds: const {}));
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
  }

  void toggleDeckSelection(int deckId) {
    if (_selectedDeckIds.contains(deckId)) {
      _selectedDeckIds.remove(deckId);
    } else {
      _selectedDeckIds.add(deckId);
    }
    emit(ImportExportDataState(
      decks: _decks,
      selectedDeckIds: _selectedDeckIds,
    ));
  }

  void selectAllDecks() {
    _selectedDeckIds
      ..clear()
      ..addAll(_decks.map((d) => d.id));
    emit(ImportExportDataState(
      decks: _decks,
      selectedDeckIds: _selectedDeckIds,
    ));
  }

  void deselectAllDecks() {
    _selectedDeckIds.clear();
    emit(ImportExportDataState(
      decks: _decks,
      selectedDeckIds: _selectedDeckIds,
    ));
  }

  Future<void> exportSelectedDecks() async {
    if (_selectedDeckIds.isEmpty) return;
    emit(const ImportExportLoadingState());
    try {
      final selectedDecks =
          _decks.where((d) => _selectedDeckIds.contains(d.id)).toList();

      await importExportService.exportDecks(selectedDecks);
      emit(ImportExportDataState(
        decks: _decks,
        selectedDeckIds: Set.from(_selectedDeckIds),
      ));
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
    loadDecks();
  }

  Future<void> importDecksFromFile() async {
    emit(const ImportExportLoadingState());
    try {
      final importedCount = await importExportService.importDecksFromFile();
      if (importedCount == null) {
        await loadDecks();
        return;
      }
      emit(ImportExportImportSuccessState(deckCount: importedCount));
      await loadDecks();
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
    loadDecks();
  }

  Future<void> importCardsFromFile() async {
    if (_decks.isEmpty) {
      emit(const ImportExportErrorState(
        exception: ImportExportException(),
      ));
      return;
    }
    emit(ImportExportSelectDeckState(decks: _decks));
  }

  Future<void> confirmImportCards(int deckId) async {
    emit(const ImportExportLoadingState());
    try {
      final importedCount =
          await importExportService.importCardsFromFile(deckId: deckId);
      if (importedCount == null) {
        await loadDecks();
        return;
      }
      emit(ImportExportImportCardsSuccessState(cardCount: importedCount));
      await loadDecks();
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
    loadDecks();
  }

  Future<void> importDecksFromClipboard() async {
    emit(const ImportExportLoadingState());
    try {
      final importedCount =
          await importExportService.importDecksFromClipboard();
      if (importedCount == null) {
        emit(const ImportExportErrorState(exception: ImportExportException()));
        await loadDecks();
        return;
      }
      emit(ImportExportImportSuccessState(deckCount: importedCount));
      await loadDecks();
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
    loadDecks();
  }

  Future<void> importCardsFromClipboard() async {
    if (_decks.isEmpty) {
      emit(const ImportExportErrorState(exception: ImportExportException()));
      return;
    }
    emit(ImportExportSelectDeckState(decks: _decks, fromClipboard: true));
  }

  Future<void> confirmImportCardsFromClipboard(int deckId) async {
    emit(const ImportExportLoadingState());
    try {
      final importedCount =
          await importExportService.importCardsFromClipboard(deckId: deckId);
      if (importedCount == null) {
        emit(const ImportExportErrorState(exception: ImportExportException()));
        await loadDecks();
        return;
      }
      emit(ImportExportImportCardsSuccessState(cardCount: importedCount));
      await loadDecks();
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to load decks', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
  }
}
