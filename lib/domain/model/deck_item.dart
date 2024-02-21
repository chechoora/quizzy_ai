class DeckItem {
  final int id;
  final String title;

  DeckItem(this.id, this.title);
}

class QuizCardItem {
  final int id;
  final int deckId;
  final String questionText;
  final String answerText;

  QuizCardItem(
    this.id,
    this.deckId,
    this.questionText,
    this.answerText,
  );
}
