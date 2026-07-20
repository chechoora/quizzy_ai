import 'package:equatable/equatable.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';

class GeneratedRemoteDeck extends Equatable {
  final List<RemoteCardDraft> cards;
  final Object? notice;

  const GeneratedRemoteDeck({
    required this.cards,
    this.notice,
  });

  @override
  List<Object?> get props => [cards, notice];
}
