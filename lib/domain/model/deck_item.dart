import 'package:equatable/equatable.dart';

class DeckItem {
  final int id;
  final String title;

  DeckItem(this.id, this.title);
}

class QuizCardItem extends Equatable {
  final int id;
  final int deckId;
  final String questionText;
  final String answerText;

  const QuizCardItem(
    this.id,
    this.deckId,
    this.questionText,
    this.answerText,
  );

  @override
  List<Object?> get props => [
        id,
        deckId,
        questionText,
        answerText,
      ];
}
