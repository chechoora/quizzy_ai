import 'package:poc_ai_quiz/domain/ai_gen/i_deck_generator.dart';
import 'package:poc_ai_quiz/domain/exception/deck_generation_exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';

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

/// Generates quiz decks (title + cards) from a natural-language prompt,
/// delegating to whichever [IDeckGenerator] matches the user's currently
/// selected deck generation provider.
class AiGenService {
  AiGenService({
    required this.settingsService,
    required this.generators,
  });

  final SettingsService settingsService;
  final Map<AnswerValidatorType, IDeckGenerator> generators;

  Future<PlainDeckModel> generate(AiGenRequest request) async {
    final type = await settingsService.getCurrentDeckGenerationAiType();
    final generator = generators[type];
    if (generator == null) {
      throw DeckGenerationException('No deck generator for $type');
    }
    return generator.generate(request);
  }
}
