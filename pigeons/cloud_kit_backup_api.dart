import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/data/api/cloud_kit_backup/generated/cloud_kit_backup.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/CloudKitBackupApi.swift',
  // Unique error class name so the generated boilerplate doesn't collide with
  // the PigeonError declared by the on_device_ai generated Swift file.
  swiftOptions: SwiftOptions(errorClassName: 'CloudKitBackupError'),
  dartPackageName: 'poc_ai_quiz',
))

/// Mirrors CKAccountStatus.
enum IcloudAccountStatus {
  available,
  noAccount,
  restricted,
  couldNotDetermine,
  temporarilyUnavailable,
}

/// Metadata stored alongside the single backup record.
class BackupMetadata {
  BackupMetadata({
    required this.updatedAtEpochMs,
    required this.deviceName,
    required this.deckCount,
    required this.cardCount,
    required this.version,
  });

  /// Record modification time, epoch milliseconds.
  final int updatedAtEpochMs;
  final String deviceName;
  final int deckCount;
  final int cardCount;
  final String version;
}

@HostApi()
abstract class CloudKitBackupApi {
  /// Current iCloud account status for the app's CloudKit container.
  @async
  IcloudAccountStatus accountStatus();

  /// Overwrites the single backup record with [jsonPayload] (stored as a
  /// CKAsset) plus metadata fields.
  @async
  void saveBackup(
    String jsonPayload,
    int deckCount,
    int cardCount,
    String version,
  );

  /// Metadata of the backup record, or null if none exists.
  @async
  BackupMetadata? fetchBackupMetadata();

  /// The JSON payload of the backup record, or null if none exists.
  @async
  String? fetchBackupPayload();
}
