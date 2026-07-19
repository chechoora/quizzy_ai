import 'dart:convert';

import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';

class ExportService {
  ExportService({required this.quizCardRepository});

  final QuizCardRepository quizCardRepository;

  Future<String> exportDecksToJson(List<DeckItem> decks) async {
    final exportData = <Map<String, dynamic>>[];

    for (final deck in decks) {
      final cards = await quizCardRepository.fetchQuizCardItem(deck.id);
      exportData.add({
        // Internal, optional id used for idempotent iCloud restore (dedupe).
        'id': deck.uid,
        'title': deck.title,
        'cards': cards
            .map((c) => {
                  'id': c.uid,
                  'question': c.questionText,
                  'answer': c.answerText,
                })
            .toList(),
      });
    }

    return jsonEncode({'decks': exportData});
  }
}