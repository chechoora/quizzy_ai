import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';

/// Input for creating a deck (optionally with an initial set of cards).
class NewRemoteDeck extends Equatable {
  final String title;
  final List<RemoteCardDraft>? cards;

  const NewRemoteDeck({
    required this.title,
    this.cards,
  });

  @override
  List<Object?> get props => [title, cards];
}
