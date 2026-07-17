import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/data/premium/premium_info.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_backup_service.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:share_plus/share_plus.dart';

class ImportExportService {
  ImportExportService({
    required this.importService,
    required this.exportService,
    required this.deckRepository,
    required this.quizCardRepository,
    required this.inAppPurchaseService,
    required this.icloudBackupService,
  });

  final ImportService importService;
  final ExportService exportService;
  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final InAppPurchaseService inAppPurchaseService;
  final IcloudBackupService icloudBackupService;

  final _logger = Logger.withTag('ImportExportService');

  Future<void> exportDecks(
    List<DeckItem> decks, {
    Rect? sharePositionOrigin,
  }) async {
    final jsonString = await exportService.exportDecksToJson(decks);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/quizzy_export.json');
    await file.writeAsString(jsonString);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: sharePositionOrigin,
      ),
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
          ImportExportType.deck,
          PremiumLimitInfo.deckLimit,
        );
      }
    }

    if (!isPremium) {
      for (final deck in decks) {
        if (deck.cards.length > PremiumLimitInfo.quizCardLimit) {
          throw const ImportLimitExceededException(
            ImportExportType.card,
            PremiumLimitInfo.quizCardLimit,
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

  /// Whether an iCloud backup record currently exists.
  Future<BackupMetadata?> icloudBackupMetadata() {
    return icloudBackupService.fetchBackupMetadata();
  }

  Future<IcloudAccountStatus> icloudAccountStatus() {
    return icloudBackupService.accountStatus();
  }

  /// Restores decks/cards from the iCloud backup, deduping by uid so repeated
  /// restores never create duplicates. Enforces the same premium limits as
  /// import (counting only net-new rows). Returns the number of restored
  /// decks, or null if there is no backup.
  Future<int?> restoreFromICloud() async {
    _logger.i('restoreFromICloud: fetching backup payload');
    final json = await icloudBackupService.fetchBackupPayload();
    if (json == null) {
      _logger.i('restoreFromICloud: no backup payload, nothing to restore');
      return null;
    }

    final backupDecks = importService.parseDecksFromJson(json);
    _logger.d('restoreFromICloud: parsed ${backupDecks.length} deck(s) '
        'from backup');

    final existingDecks = await deckRepository.fetchDecks();
    final existingDeckIdByUid = <int, int>{
      for (final d in existingDecks)
        if (d.uid != null) d.uid!: d.id,
    };

    int? deckIdForBackup(PlainDeckModel deck) =>
        deck.uid == null ? null : existingDeckIdByUid[deck.uid];

    // Premium gate (enforce), counting only net-new rows after dedupe.
    final isPremium = await inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards);
    if (!isPremium) {
      var projectedDeckCount = existingDecks.length;
      for (final deck in backupDecks) {
        final existingDeckId = deckIdForBackup(deck);
        if (existingDeckId == null) {
          projectedDeckCount++;
          if (deck.cards.length > PremiumLimitInfo.quizCardLimit) {
            throw const ImportLimitExceededException(
              ImportExportType.card,
              PremiumLimitInfo.quizCardLimit,
            );
          }
        } else {
          final existingUids =
              await quizCardRepository.fetchCardUids(existingDeckId);
          final newCards = deck.cards
              .where((c) => c.uid == null || !existingUids.contains(c.uid))
              .length;
          if (existingUids.length + newCards >
              PremiumLimitInfo.quizCardLimit) {
            throw const ImportLimitExceededException(
              ImportExportType.card,
              PremiumLimitInfo.quizCardLimit,
            );
          }
        }
      }
      if (projectedDeckCount > PremiumLimitInfo.deckLimit) {
        throw const ImportLimitExceededException(
          ImportExportType.deck,
          PremiumLimitInfo.deckLimit,
        );
      }
    }
    _logger.d('restoreFromICloud: premium=$isPremium, limit checks passed');

    // Upsert by uid.
    var restoredDeckCount = 0;
    var insertedDecks = 0;
    var mergedDecks = 0;
    for (final deck in backupDecks) {
      final existingDeckId = deckIdForBackup(deck);
      if (existingDeckId == null) {
        final deckId = deck.uid != null
            ? await deckRepository.saveDeckWithUid(deck.title, deck.uid!)
            : await deckRepository.saveDeck(deck.title);
        if (deckId == -1) continue;
        await quizCardRepository.saveCardsWithUid(deck.cards, deckId);
        insertedDecks++;
      } else {
        final existingUids =
            await quizCardRepository.fetchCardUids(existingDeckId);
        final newCards = <PlainCardModel>[];
        var updatedCards = 0;
        for (final card in deck.cards) {
          if (card.uid != null && existingUids.contains(card.uid)) {
            await quizCardRepository.updateCardByUid(existingDeckId, card);
            updatedCards++;
          } else {
            newCards.add(card);
          }
        }
        if (newCards.isNotEmpty) {
          await quizCardRepository.saveCardsWithUid(newCards, existingDeckId);
        }
        mergedDecks++;
        _logger.d('restoreFromICloud: merged deck "${deck.title}" '
            '($updatedCards updated, ${newCards.length} new cards)');
      }
      restoredDeckCount++;
    }
    _logger.i('restoreFromICloud: restored $restoredDeckCount deck(s) '
        '($insertedDecks inserted, $mergedDecks merged)');
    return restoredDeckCount;
  }
}
