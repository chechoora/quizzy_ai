import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_backup_service.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Owns the one-time "offer restore from iCloud on a clean install" flag and
/// the decision of whether to offer it, analogous to `OnboardingService`.
///
/// The flag lives in shared preferences (not the DB) so it is independent of
/// the freshly-created local database on a clean install.
class ICloudRestoreService {
  ICloudRestoreService({
    required this.prefs,
    required this.deckRepository,
    required this.icloudBackupService,
    required this.importExportService,
  });

  static const _promptShownKey = 'icloud_restore_prompt_shown';

  final SharedPreferences prefs;
  final DeckRepository deckRepository;
  final IcloudBackupService icloudBackupService;
  final ImportExportService importExportService;

  final _logger = Logger.withTag('ICloudRestoreService');

  bool get isSupported => Platform.isIOS;

  bool get hasPromptBeenShown => prefs.getBool(_promptShownKey) ?? false;

  Future<void> markPromptShown() {
    _logger.d('markPromptShown: setting flag');
    return prefs.setBool(_promptShownKey, true);
  }

  /// Whether to offer the clean-install restore prompt: iOS, not shown before,
  /// empty local DB, iCloud available, and a backup record exists.
  Future<bool> shouldOfferRestore() async {
    if (!isSupported) {
      _logger.d('shouldOfferRestore: false (unsupported platform)');
      return false;
    }
    if (hasPromptBeenShown) {
      _logger.d('shouldOfferRestore: false (already shown)');
      return false;
    }
    final decks = await deckRepository.fetchDecks();
    if (decks.isNotEmpty) {
      _logger.d('shouldOfferRestore: false (local DB not empty: '
          '${decks.length} decks)');
      return false;
    }
    if (!await icloudBackupService.isAvailable()) {
      _logger.d('shouldOfferRestore: false (iCloud unavailable)');
      return false;
    }
    final metadata = await icloudBackupService.fetchBackupMetadata();
    final shouldOffer = metadata != null;
    _logger.i('shouldOfferRestore: $shouldOffer '
        '(backup ${shouldOffer ? "found" : "absent"})');
    return shouldOffer;
  }

  /// Restores decks/cards from the iCloud backup. Returns the number of
  /// restored decks, or null if there is no backup.
  Future<int?> restore() async {
    _logger.i('restore: starting');
    try {
      final count = await importExportService.restoreFromICloud();
      _logger.i('restore: finished, ${count ?? 0} deck(s) restored'
          '${count == null ? " (no backup)" : ""}');
      return count;
    } catch (e, s) {
      _logger.e('restore failed', ex: e, stacktrace: s);
      rethrow;
    }
  }
}
