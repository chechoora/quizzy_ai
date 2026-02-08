import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';

class HomeCubit extends Cubit<DeckState> {
  HomeCubit({
    required this.deckRepository,
    required this.deckPremiumManager,
  }) : super(const DeckLoadingState());

  final DeckRepository deckRepository;
  final DeckPremiumManager deckPremiumManager;
  final List<DeckItemWithPremium> decks = [];

  Future<void> fetchDecks() async {
    emit(const DeckLoadingState());
    final data = await deckPremiumManager.fetchAllowedDecks();
    decks
      ..clear()
      ..addAll(data);
    emit(DeckDataState(data));
  }

  Future<void> createDeck(String deckName) async {
    emit(const DeckLoadingState());
    deckRepository.saveDeck(deckName);
    fetchDecks();
  }

  void deleteDeck(DeckItem deck) {
    emit(const DeckLoadingState());
    deckRepository.deleteDeck(deck);
    fetchDecks();
  }

  void editDeck(DeckItem deck, String deckName) {
    emit(const DeckLoadingState());
    deckRepository.editDeckName(deck, deckName);
    fetchDecks();
  }

  void addDockRequest() async {
    final canAddDecks = await deckPremiumManager.canAddDeck();
    emit(
      RequestCreateDeckState(
        canCreateDeck: canAddDecks,
      ),
    );
  }
}

abstract class DeckState extends Equatable {
  const DeckState();
}

abstract class BuilderState extends DeckState {
  const BuilderState();
}

abstract class ListenerState extends DeckState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class DeckLoadingState extends BuilderState {
  const DeckLoadingState();

  @override
  List<Object?> get props => [];
}

class DeckDataState extends BuilderState {
  final List<DeckItemWithPremium> deckList;

  const DeckDataState(this.deckList);

  @override
  List<Object?> get props => [deckList];
}

class RequestCreateDeckState extends ListenerState {
  final bool canCreateDeck;

  const RequestCreateDeckState({
    required this.canCreateDeck,
  });
}
