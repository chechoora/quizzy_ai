import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/decks_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card_draft.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Generates decks via the Quizzy backend, which owns the prompt and the model
/// choice — hence [buildGenerationPrompt] goes unused here.
class DecksDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('DecksDeckGenerator');

  final DecksRepository _repository;

  DecksDeckGenerator(this._repository);

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.i('Generating deck with Quizzy AI');
      _logger.v('Prompt: ${request.prompt}');

      final result = await _repository.generateDeck(
        prompt: request.prompt,
        deckTitle: request.deckTitle,
        currentCards: request.currentCards
            .map((c) => RemoteCardDraft(question: c.question, answer: c.answer))
            .toList(),
      );

      if (result.cards.isEmpty) {
        throw DeckGenerationException('Response contained no cards');
      }

      final deck = PlainDeckModel(
        title: request.deckTitle ?? '',
        cards: result.cards
            .map((c) => PlainCardModel(question: c.question, answer: c.answer))
            .toList(),
      );

      _logger.i('Generated ${deck.cards.length} cards');
      return deck;
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with Quizzy AI',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
