import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';

import 'package:poc_ai_quiz/data/premium/premium_info.dart';

class DeckPremiumManager {
  final UserRepository userRepository;
  final DeckRepository deckRepository;

  DeckPremiumManager({
    required this.userRepository,
    required this.deckRepository,
  });

  Future<List<DeckItemWithPremium>> fetchAllowedDecks() async {
    final allDecks = await deckRepository.fetchDecks();
    final user = await userRepository.fetchCurrentUser();
    int count = 0;
    return allDecks.map((deck) {
      return DeckItemWithPremium.fromDeck(
        deckItem: deck,
        isLocked: !user.isPremium && ++count < PremiumLimitInfo.deckLimit,
      );
    }).toList();
  }

  Future<bool> canAddDeck() async {
    final allDecks = await deckRepository.fetchDecks();
    return allDecks.length < PremiumLimitInfo.deckLimit;
  }
}
