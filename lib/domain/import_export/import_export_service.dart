import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/data/premium/premium_info.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
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

  Future<int> _saveImportedDecks(List<DeckImportModel> decks) async {
    final isPremium = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);

    if (!isPremium) {
      final existingDecks = await deckRepository.fetchDecks();
      final totalAfterImport = existingDecks.length + decks.length;
      if (totalAfterImport > PremiumLimitInfo.deckLimit) {
        // TODO: Move to .arb
        throw const ImportLimitExceededException(
          'Deck limit exceeded. Please purchase full version. You can have up to ${PremiumLimitInfo.deckLimit} decks.',
        );
      }
    }

    if (!isPremium) {
      for (final deck in decks) {
        if (deck.cards.length > PremiumLimitInfo.quizCardLimit) {
          throw const ImportLimitExceededException(
            'Card limit exceeded. Please purchase full version. Each deck can have up to '
            '${PremiumLimitInfo.quizCardLimit} cards.',
          );
        }
      }
    }

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

  Future<int> _saveImportedCards(
    List<CardImportModel> cards, {
    required int deckId,
  }) async {
    final isPremium = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);

    if (!isPremium) {
      final allDecks = await deckRepository.fetchDecks();
      final deck = allDecks.firstWhere((d) => d.id == deckId);
      final existingCards = await quizCardRepository.fetchQuizCardItem(deck);
      final totalAfterImport = existingCards.length + cards.length;
      if (totalAfterImport > PremiumLimitInfo.quizCardLimit) {
        throw const ImportLimitExceededException(
          'Card limit exceeded. Each deck can have up to '
          '${PremiumLimitInfo.quizCardLimit} cards.',
        );
      }
    }

    var importedCount = 0;
    for (final card in cards) {
      await quizCardRepository.saveQuizCard(
        question: card.question,
        answer: card.answer,
        deckId: deckId,
      );
      importedCount++;
    }
    return importedCount;
  }
}

class ImportLimitExceededException implements Exception {
  const ImportLimitExceededException(this.message);

  final String message;

  @override
  String toString() => message;
}
