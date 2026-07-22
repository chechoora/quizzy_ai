import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_backup_service.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/view/import_export/cubit/import_export_state.dart';

final _logger = Logger.withTag('ImportExportCubit');

class ImportExportCubit extends Cubit<ImportExportState> {
  ImportExportCubit({
    required this.deckRepository,
    required this.importExportService,
    required this.isSubscriptionOnly,
  }) : super(const ImportExportLoadingState());

  final DeckRepository deckRepository;
  final ImportExportService importExportService;

  /// When true (the `quizzypro` flavor) only the Quizzy AI subscription is
  /// offered; when false (the `quizzy` flavor) only the one-time "unlimited
  /// decks/cards" purchase is offered.
  final bool isSubscriptionOnly;

  final List<DeckItem> _decks = [];
  final Set<int> _selectedDeckIds = {};

  /// The purchase feature to offer when an import/export limit is hit,
  /// resolved from the active flavor: `quizzyAi` subscription on
  /// `quizzypro`, the one-time `unlimitedDecksCards` purchase on `quizzy`.
  InAppPurchaseFeature get unlockFeature => isSubscriptionOnly
      ? InAppPurchaseFeature.quizzyAi
      : InAppPurchaseFeature.unlimitedDecksCards;

  IcloudAccountStatus? _iCloudStatus;
  DateTime? _iCloudLastBackup;

  ImportExportDataState _buildDataState() {
    return ImportExportDataState(
      decks: _decks,
      selectedDeckIds: Set.from(_selectedDeckIds),
      iCloudStatus: _iCloudStatus,
      iCloudLastBackup: _iCloudLastBackup,
    );
  }

  Future<void> loadDecks() async {
    emit(const ImportExportLoadingState());
    try {
      _decks
        ..clear()
        ..addAll(await deckRepository.fetchDecks());
      _selectedDeckIds.clear();
      emit(_buildDataState());
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
    emit(_buildDataState());
  }

  void selectAllDecks() {
    _selectedDeckIds
      ..clear()
      ..addAll(_decks.map((d) => d.id));
    emit(_buildDataState());
  }

  void deselectAllDecks() {
    _selectedDeckIds.clear();
    emit(_buildDataState());
  }

  Future<void> exportSelectedDecks([Rect? sharePositionOrigin]) async {
    if (_selectedDeckIds.isEmpty) return;
    emit(const ImportExportLoadingState());
    try {
      final selectedDecks =
          _decks.where((d) => _selectedDeckIds.contains(d.id)).toList();

      await importExportService.exportDecks(
        selectedDecks,
        sharePositionOrigin: sharePositionOrigin,
      );
      emit(_buildDataState());
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

  /// Loads iCloud account status and last-backup date, then re-emits the data
  /// state so the iCloud tile reflects it. Safe to call on any platform.
  Future<void> loadICloudStatus() async {
    try {
      _iCloudStatus = await importExportService.icloudAccountStatus();
      final metadata = await importExportService.icloudBackupMetadata();
      _iCloudLastBackup = metadata == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(metadata.updatedAtEpochMs);
    } catch (e, stackTrace) {
      _logger.e('Failed to load iCloud status', ex: e, stacktrace: stackTrace);
    }
    if (state is ImportExportDataState) {
      emit(_buildDataState());
    }
  }

  Future<void> restoreFromICloud() async {
    emit(const ImportExportLoadingState());
    try {
      final restoredCount = await importExportService.restoreFromICloud();
      if (restoredCount == null) {
        emit(const ImportExportICloudRestoreEmptyState());
        await loadDecks();
        return;
      }
      emit(ImportExportICloudRestoreSuccessState(deckCount: restoredCount));
    } on ImportExportException catch (e, stackTrace) {
      _logger.e('Failed to restore from iCloud', ex: e, stacktrace: stackTrace);
      emit(ImportExportErrorState(exception: e));
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to restore from iCloud', ex: e, stacktrace: stackTrace);
      emit(const ImportExportErrorState(exception: ImportExportException()));
    }
    await loadDecks();
    await loadICloudStatus();
  }
}
