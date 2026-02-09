import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/data/premium/premium_info.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/import_export/exception.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImportExportService {
  ImportExportService({
    required this.importService,
    required this.exportService,
    required this.deckRepository,
    required this.quizCardRepository,
    required this.inAppPurchaseService,
  });

  final ImportService importService;
  final ExportService exportService;
  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;

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
    return _saveImportedDecks(decks);
  }

  /// Returns the number of imported cards, or null if the user cancelled.
  Future<int?> importCardsFromFile({required int deckId}) async {
    final cards = await importService.importCardsFromFile();
    if (cards == null) return null;
    return _saveImportedCards(cards, deckId: deckId);
  }

  Future<int?> importDecksFromClipboard() async {
    final decks = await importService.importDecksFromClipboard();
    if (decks == null) return null;
    return _saveImportedDecks(decks);
  }

  Future<int?> importCardsFromClipboard({required int deckId}) async {
    final cards = await importService.importCardsFromClipboard();
    if (cards == null) return null;
    return _saveImportedCards(cards, deckId: deckId);
  }

  Future<int> _saveImportedDecks(List<PlainDeckModel> decks) async {
    final isPremium = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);

    if (!isPremium) {
      final existingDecks = await deckRepository.fetchDecks();
      final totalAfterImport = existingDecks.length + decks.length;
      if (totalAfterImport > PremiumLimitInfo.deckLimit) {
        throw const ImportLimitExceededException(
          ImportExportType.card,
          PremiumLimitInfo.quizCardLimit,
        );
      }
    }

    if (!isPremium) {
      for (final deck in decks) {
        if (deck.cards.length > PremiumLimitInfo.quizCardLimit) {
          throw const ImportLimitExceededException(
            ImportExportType.deck,
            PremiumLimitInfo.deckLimit,
          );
        }
      }
    }

    var importedCount = 0;
    for (final deck in decks) {
      final deckId = await deckRepository.saveDeck(deck.title);
      if (deckId == -1) continue;

      await quizCardRepository.saveQuizCards(deck.cards, deckId);
      importedCount++;
    }
    return importedCount;
  }

  Future<int> _saveImportedCards(
    List<PlainCardModel> cards, {
    required int deckId,
  }) async {
    final isPremium = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);

    if (!isPremium) {
      final existingCards = await quizCardRepository.fetchQuizCardItem(deckId);
      final totalAfterImport = existingCards.length + cards.length;
      if (totalAfterImport > PremiumLimitInfo.quizCardLimit) {
        throw const ImportLimitExceededException(
          ImportExportType.card,
          PremiumLimitInfo.quizCardLimit,
        );
      }
    }

    return (await quizCardRepository.saveQuizCards(cards, deckId)).length;
  }
}
