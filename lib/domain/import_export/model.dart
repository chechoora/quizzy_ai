class PlainDeckModel {
  final String title;
  final List<PlainCardModel> cards;

  PlainDeckModel({
    required this.title,
    required this.cards,
  });
}

class PlainCardModel {
  final String question;
  final String answer;

  PlainCardModel({
    required this.question,
    required this.answer,
  });
}
