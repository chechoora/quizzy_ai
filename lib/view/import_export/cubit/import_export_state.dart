import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

// -- States --

abstract class ImportExportState extends Equatable {
  const ImportExportState();
}

abstract class BuilderState extends ImportExportState {
  const BuilderState();
}

abstract class ListenerState extends ImportExportState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

// Builder States

class ImportExportLoadingState extends BuilderState {
  const ImportExportLoadingState();

  @override
  List<Object?> get props => [];
}

class ImportExportDataState extends BuilderState with UniqueEmit {
  const ImportExportDataState({
    required this.decks,
    required this.selectedDeckIds,
  });

  final List<DeckItem> decks;
  final Set<int> selectedDeckIds;

  bool get hasSelection => selectedDeckIds.isNotEmpty;

  bool get allSelected =>
      decks.isNotEmpty && selectedDeckIds.length == decks.length;

  ImportExportDataState copyWith({
    List<DeckItem>? decks,
    Set<int>? selectedDeckIds,
  }) {
    return ImportExportDataState(
      decks: decks ?? this.decks,
      selectedDeckIds: selectedDeckIds ?? this.selectedDeckIds,
    );
  }

  @override
  List<Object?> get props => uniqueProps;
}

// Listener States

class ImportExportSelectDeckState extends ListenerState {
  const ImportExportSelectDeckState({
    required this.decks,
    this.fromClipboard = false,
  });

  final List<DeckItem> decks;
  final bool fromClipboard;
}

class ImportExportErrorState extends ListenerState {
  const ImportExportErrorState({required this.message});

  final String message;
}

class ImportExportImportSuccessState extends ListenerState {
  const ImportExportImportSuccessState({required this.deckCount});

  final int deckCount;
}

class ImportExportImportCardsSuccessState extends ListenerState {
  const ImportExportImportCardsSuccessState({required this.cardCount});

  final int cardCount;
}
