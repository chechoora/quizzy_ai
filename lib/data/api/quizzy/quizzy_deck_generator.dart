import 'package:poc_ai_quiz/data/api/quizzy/quizzy_api_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/ai_gen/model/generated_deck.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Generates decks via the Quizzy backend, which owns the prompt and the model
/// choice — hence [buildGenerationPrompt] goes unused here.
class QuizzyDeckGenerator extends IDeckGenerator {
  static final _logger = Logger.withTag('QuizzyDeckGenerator');

  final QuizzyApiService _apiService;
  final InAppPurchaseService _inAppPurchaseService;

  QuizzyDeckGenerator(this._apiService, this._inAppPurchaseService);

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    try {
      _logger.d('Generating deck with Quizzy AI');
      _logger.v('Prompt: ${request.prompt}');

      final appUserId = await _inAppPurchaseService.getAppUserId();
      final response = await _apiService.generateDeck(
        userId: appUserId,
        body: GenerateDeckRequest(
          prompt: request.prompt,
          deckTitle: request.deckTitle,
          currentCards: request.currentCards,
        ),
      );

      if (response.statusCode != 200 || response.body == null) {
        _logger.e('Quizzy API request failed with status ${response.statusCode}');
        throw DeckGenerationException(
            'Failed to generate deck: ${response.statusCode}, ${response.error}');
      }

      final deck =
          GeneratedDeck.fromJson(response.body as Map<String, dynamic>);

      _logger.i('Generated ${deck.cards.length} cards');
      return deck.toPlainDeck();
    } catch (e, stackTrace) {
      _logger.e('Error generating deck with Quizzy AI',
          ex: e, stacktrace: stackTrace);
      rethrow;
    }
  }
}
