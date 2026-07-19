import 'dart:io';

import 'package:poc_ai_quiz/data/api/cloud_kit_backup/generated/cloud_kit_backup.g.dart';
import 'package:poc_ai_quiz/util/logger.dart';

export 'package:poc_ai_quiz/data/api/cloud_kit_backup/generated/cloud_kit_backup.g.dart'
    show IcloudAccountStatus, BackupMetadata;

/// Thin wrapper over the CloudKit backup platform channel. iOS-only; every
/// call degrades gracefully (returns a safe default / null) when the native
/// side is unavailable or errors.
class IcloudBackupService {
  IcloudBackupService({required this.enabled, CloudKitBackupApi? api})
      : _api = api ?? CloudKitBackupApi();

  /// Whether iCloud backup is enabled for this app flavor
  /// (`AppConfig.enableIcloudBackup`).
  final bool enabled;

  final CloudKitBackupApi _api;
  final _logger = Logger.withTag('IcloudBackupService');

  /// Whether iCloud backup is supported on this platform and enabled for
  /// this app flavor.
  bool get isSupported => enabled && Platform.isIOS;

  Future<IcloudAccountStatus> accountStatus() async {
    if (!isSupported) {
      _logger.d('accountStatus: unsupported platform, returning noAccount');
      return IcloudAccountStatus.noAccount;
    }
    try {
      final status = await _api.accountStatus();
      _logger.d('accountStatus: $status');
      return status;
    } catch (e, s) {
      _logger.e('accountStatus failed', ex: e, stacktrace: s);
      return IcloudAccountStatus.couldNotDetermine;
    }
  }

  /// Convenience: is an iCloud account currently usable for backup.
  Future<bool> isAvailable() async {
    final available = (await accountStatus()) == IcloudAccountStatus.available;
    _logger.d('isAvailable: $available');
    return available;
  }

  Future<void> saveBackup({
    required String jsonPayload,
    required int deckCount,
    required int cardCount,
    required String version,
  }) async {
    if (!isSupported) {
      _logger.d('saveBackup skipped: unsupported platform');
      return;
    }
    _logger.d(
      'saveBackup: uploading $deckCount decks, $cardCount cards '
      '(${jsonPayload.length} bytes, v$version)',
    );
    try {
      await _api.saveBackup(jsonPayload, deckCount, cardCount, version);
      _logger.i('saveBackup: upload succeeded');
    } catch (e, s) {
      _logger.e('saveBackup failed', ex: e, stacktrace: s);
      rethrow;
    }
  }

  Future<BackupMetadata?> fetchBackupMetadata() async {
    if (!isSupported) {
      _logger.d('fetchBackupMetadata: unsupported platform, returning null');
      return null;
    }
    try {
      final metadata = await _api.fetchBackupMetadata();
      if (metadata == null) {
        _logger.d('fetchBackupMetadata: no backup record found');
      } else {
        _logger.d(
          'fetchBackupMetadata: ${metadata.deckCount} decks, '
          '${metadata.cardCount} cards, device "${metadata.deviceName}", '
          'updatedAt ${metadata.updatedAtEpochMs}',
        );
      }
      return metadata;
    } catch (e, s) {
      _logger.e('fetchBackupMetadata failed', ex: e, stacktrace: s);
      return null;
    }
  }

  Future<String?> fetchBackupPayload() async {
    if (!isSupported) {
      _logger.d('fetchBackupPayload: unsupported platform, returning null');
      return null;
    }
    try {
      final payload = await _api.fetchBackupPayload();
      _logger.d(
        payload == null
            ? 'fetchBackupPayload: no backup payload found'
            : 'fetchBackupPayload: ${payload.length} bytes',
      );
      return payload;
    } catch (e, s) {
      _logger.e('fetchBackupPayload failed', ex: e, stacktrace: s);
      rethrow;
    }
  }
}
