import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class HomeCubit extends Cubit<DeckState> {
  HomeCubit({
    required this.deckRepository,
    required this.deckPremiumManager,
  }) : super(const DeckLoadingState());

  final DeckRepository deckRepository;
  final DeckPremiumManager deckPremiumManager;

  Future<void> fetchDecks() async {
    emit(const DeckLoadingState());
    final data = await deckPremiumManager.fetchAllowedDecks();
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
}

abstract class DeckState {
  const DeckState();
}

class DeckLoadingState extends DeckState {
  const DeckLoadingState();
}

class DeckDataState extends DeckState {
  final List<DeckItem> deckList;

  const DeckDataState(this.deckList);
}
