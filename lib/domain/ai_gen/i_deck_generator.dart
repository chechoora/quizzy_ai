import 'dart:convert';

import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';

abstract class IDeckGenerator {
  Future<void> initialize() async {}

  Future<PlainDeckModel> generate(AiGenRequest request);

  String buildGenerationPrompt(AiGenRequest request) {
    final title = request.deckTitle?.trim() ?? '';
    final deckContext = title.isEmpty
        ? ''
        : '''

This deck is titled "$title". Use it as the topic context for the cards.''';

    final refinementContext = !request.isRefinement
        ? ''
        : '''

These are the cards currently in the deck:
${_encodeCards(request.currentCards)}

Apply the user request to them and return the COMPLETE resulting set of cards,
including any card you left untouched. Do not return only the cards you changed.''';

    return """
You are an AI author of study cards for an Anki-style mobile learning application, helping students learn effectively.

Your task:
1. Write clear, self-contained cards: one idea per card, no card depending on another
2. Keep questions short and specific; keep answers correct, complete, and concise
3. Favour understanding over rote recall — prefer "why"/"how" questions where the topic allows
4. Never duplicate a question within the deck
5. Write the title and every card in the same language as the user request below
$deckContext$refinementContext

User request:
${request.prompt}""";
  }

  String _encodeCards(List<PlainCardModel> cards) {
    return const JsonEncoder.withIndent('  ').convert(
      cards
          .map((c) => {'question': c.question, 'answer': c.answer})
          .toList(),
    );
  }
}
