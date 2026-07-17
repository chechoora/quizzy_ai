class PlainDeckModel {
  final int? uid;
  final String title;
  final List<PlainCardModel> cards;

  PlainDeckModel({
    required this.title,
    required this.cards,
    this.uid,
  });
}

class PlainCardModel {
  final int? uid;
  final String question;
  final String answer;

  PlainCardModel({
    required this.question,
    required this.answer,
    this.uid,
  });
}
