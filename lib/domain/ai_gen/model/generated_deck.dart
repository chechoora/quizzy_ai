import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';

/// A deck as returned by an AI provider, before it is handed to the app as a
/// [PlainDeckModel].
class GeneratedDeck {
  final String title;
  final List<GeneratedCard> cards;

  GeneratedDeck({
    required this.title,
    required this.cards,
  });

  factory GeneratedDeck.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>?)
            ?.map((e) => GeneratedCard.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    if (cards.isEmpty) {
      throw DeckGenerationException('Response contained no cards');
    }
    return GeneratedDeck(
      title: json['title'] as String? ?? '',
      cards: cards,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  PlainDeckModel toPlainDeck() => PlainDeckModel(
        title: title,
        cards: cards.map((c) => c.toPlainCard()).toList(),
      );
}

class GeneratedCard {
  final String question;
  final String answer;

  GeneratedCard({
    required this.question,
    required this.answer,
  });

  factory GeneratedCard.fromJson(Map<String, dynamic> json) => GeneratedCard(
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };

  PlainCardModel toPlainCard() =>
      PlainCardModel(question: question, answer: answer);
}
