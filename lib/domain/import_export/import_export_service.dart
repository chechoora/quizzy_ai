import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImportExportService {
  ImportExportService({
    required this.importService,
    required this.exportService,
    required this.deckRepository,
    required this.quizCardRepository,
  });

  final ImportService importService;
  final ExportService exportService;
  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;

  Future<void> exportDecks(List<DeckItem> decks) async {
    final jsonString = await exportService.exportDecksToJson(decks);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/quizzy_export.json');
    await file.writeAsString(jsonString);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  /// Returns the number of imported decks, or null if the user cancelled.
  Future<int?> importDecksFromFile() async {
    final decks = await importService.importDecksFromFile();
    if (decks == null) return null;

    var importedCount = 0;

    for (final deck in decks) {
      final saved = await deckRepository.saveDeck(deck.title);
      if (!saved) continue;

      final allDecks = await deckRepository.fetchDecks();
      final newDeck = allDecks.lastWhere((d) => d.title == deck.title);

      for (final card in deck.cards) {
        await quizCardRepository.saveQuizCard(
          question: card.question,
          answer: card.answer,
          deckId: newDeck.id,
        );
      }
      importedCount++;
    }

    return importedCount;
  }
}