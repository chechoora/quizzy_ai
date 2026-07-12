import 'package:poc_ai_quiz/domain/import_export/model.dart';

/// Request passed to [AiGenService] to generate or refine a set of quiz cards.
class AiGenRequest {
  const AiGenRequest({
    required this.prompt,
    this.deckTitle,
    this.currentCards = const [],
  });

  /// Free-form user instruction describing the deck / refinement.
  final String prompt;

  /// Optional user-provided deck title.
  final String? deckTitle;

  /// Cards currently on screen. Empty on the first generation, populated when
  /// the user asks to refine an already-generated set.
  final List<PlainCardModel> currentCards;

  bool get isRefinement => currentCards.isNotEmpty;
}

/// Generates quiz decks (title + cards) from a natural-language prompt.
///
/// Mocked for now via [MockAiGenService]; a real implementation would call an
/// LLM backend and return the same [PlainDeckModel] shape.
abstract class AiGenService {
  Future<PlainDeckModel> generate(AiGenRequest request);
}
