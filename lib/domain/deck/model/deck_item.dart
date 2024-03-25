import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/premium_info.dart';

class DeckItem extends Equatable {
  final int id;
  final String title;
  final bool isArchive;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        isArchive,
      ];
}

class DeckItemWithPremium extends DeckItem with PremiumInfo {
  DeckItemWithPremium({
    required super.id,
    required super.title,
    required super.isArchive,
    required bool isLocked,
  }) {
    isObjectLocked = isLocked;
  }

  factory DeckItemWithPremium.fromDeck({
    required DeckItem deckItem,
    required bool isLocked,
  }) {
    return DeckItemWithPremium(
      id: deckItem.id,
      title: deckItem.title,
      isArchive: deckItem.isArchive,
      isLocked: isLocked,
    );
  }

  @override
  List<Object?> get props => super.props..add(isObjectLocked);
}
