import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Mock [AiGenService] that returns canned cards after a short delay so the
/// full generate / refine / save flow can be exercised without a backend.
class MockAiGenService implements AiGenService {
  MockAiGenService();

  final _logger = Logger.withTag('MockAiGenService');

  static const _generationDelay = Duration(milliseconds: 1200);

  @override
  Future<PlainDeckModel> generate(AiGenRequest request) async {
    _logger.d(
      'generate(prompt: "${request.prompt}", '
      'refinement: ${request.isRefinement}, '
      'currentCards: ${request.currentCards.length})',
    );
    await Future.delayed(_generationDelay);

    final title = _resolveTitle(request);

    if (request.isRefinement) {
      // Refinement: keep the existing cards and append one extra so the effect
      // of the follow-up prompt is visible on screen.
      final refined = List<PlainCardModel>.from(request.currentCards)
        ..add(
          PlainCardModel(
            question: 'Refined: ${request.prompt}',
            answer: 'Updated answer #${request.currentCards.length + 1}',
          ),
        );
      return PlainDeckModel(title: title, cards: refined);
    }

    return PlainDeckModel(title: title, cards: _mockCards(request.prompt));
  }

  String _resolveTitle(AiGenRequest request) {
    final userTitle = request.deckTitle?.trim();
    if (userTitle != null && userTitle.isNotEmpty) {
      return userTitle;
    }
    final prompt = request.prompt.trim();
    if (prompt.isEmpty) {
      return 'New AI Deck';
    }
    final words = prompt.split(RegExp(r'\s+')).take(4).join(' ');
    return words.isEmpty ? 'New AI Deck' : words;
  }

  List<PlainCardModel> _mockCards(String prompt) {
    final topic = prompt.trim().isEmpty ? 'the topic' : prompt.trim();
    return [
      PlainCardModel(
        question: 'What is a key concept in $topic?',
        answer: 'A fundamental idea related to $topic.',
      ),
      PlainCardModel(
        question: 'Give an example related to $topic.',
        answer: 'An illustrative example of $topic.',
      ),
      PlainCardModel(
        question: 'Why is $topic important?',
        answer: 'It matters because of its practical applications.',
      ),
      PlainCardModel(
        question: 'Name a common misconception about $topic.',
        answer: 'A frequently misunderstood aspect of $topic.',
      ),
    ];
  }
}
