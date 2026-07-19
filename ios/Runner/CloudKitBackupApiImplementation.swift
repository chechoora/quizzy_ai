import Foundation
import CloudKit
import UIKit

/// CloudKit-backed implementation of the deck/card iCloud backup channel.
///
/// Persists a single record (fixed recordName "deck_backup") in the user's
/// private database, storing the JSON payload as a CKAsset plus metadata
/// fields. Each save overwrites the same record — one backup, no history.
class CloudKitBackupApiImplementation: CloudKitBackupApi {

    private let containerIdentifier = "iCloud.com.chechoora.quizzy"
    private let recordType = "DeckBackup"
    private let recordName = "deck_backup"

    // Field keys
    private let fieldPayload = "payload"
    private let fieldUpdatedAt = "updatedAt"
    private let fieldDeviceName = "deviceName"
    private let fieldDeckCount = "deckCount"
    private let fieldCardCount = "cardCount"
    private let fieldVersion = "version"

    private var container: CKContainer {
        CKContainer(identifier: containerIdentifier)
    }

    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    private var recordID: CKRecord.ID {
        CKRecord.ID(recordName: recordName)
    }

    // MARK: - CloudKitBackupApi

    func accountStatus(completion: @escaping (Result<IcloudAccountStatus, Error>) -> Void) {
        container.accountStatus { status, error in
            if let error = error {
                completion(.failure(CloudKitBackupError(
                    code: "ACCOUNT_STATUS_ERROR",
                    message: error.localizedDescription,
                    details: nil
                )))
                return
            }
            completion(.success(self.mapAccountStatus(status)))
        }
    }

    func saveBackup(
        jsonPayload: String,
        deckCount: Int64,
        cardCount: Int64,
        version: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Write the payload to a temporary file for the CKAsset.
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck_backup_\(UUID().uuidString).json")
        do {
            try jsonPayload.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            completion(.failure(CloudKitBackupError(
                code: "WRITE_TEMP_FAILED",
                message: error.localizedDescription,
                details: nil
            )))
            return
        }

        fetchRecord { result in
            let record: CKRecord
            switch result {
            case .success(let existing):
                record = existing ?? CKRecord(recordType: self.recordType, recordID: self.recordID)
            case .failure(let error):
                completion(.failure(error))
                return
            }

            record[self.fieldPayload] = CKAsset(fileURL: tempURL)
            record[self.fieldUpdatedAt] = Date() as CKRecordValue
            record[self.fieldDeviceName] = UIDevice.current.name as CKRecordValue
            record[self.fieldDeckCount] = NSNumber(value: deckCount)
            record[self.fieldCardCount] = NSNumber(value: cardCount)
            record[self.fieldVersion] = version as CKRecordValue

            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            // Overwrite the server record unconditionally — one backup, no history.
            operation.savePolicy = .allKeys
            // `modifyRecordsCompletionBlock` (deprecated in iOS 15) is used for
            // iOS 13 compatibility; `modifyRecordsResultBlock` needs iOS 15+.
            operation.modifyRecordsCompletionBlock = { _, _, error in
                try? FileManager.default.removeItem(at: tempURL)
                if let error = error {
                    completion(.failure(CloudKitBackupError(
                        code: "SAVE_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    )))
                } else {
                    completion(.success(()))
                }
            }
            self.privateDatabase.add(operation)
        }
    }

    func fetchBackupMetadata(completion: @escaping (Result<BackupMetadata?, Error>) -> Void) {
        fetchRecord { result in
            switch result {
            case .success(let record):
                guard let record = record else {
                    completion(.success(nil))
                    return
                }
                let updatedAt = (record[self.fieldUpdatedAt] as? Date) ?? Date()
                let metadata = BackupMetadata(
                    updatedAtEpochMs: Int64(updatedAt.timeIntervalSince1970 * 1000),
                    deviceName: (record[self.fieldDeviceName] as? String) ?? "",
                    deckCount: (record[self.fieldDeckCount] as? NSNumber)?.int64Value ?? 0,
                    cardCount: (record[self.fieldCardCount] as? NSNumber)?.int64Value ?? 0,
                    version: (record[self.fieldVersion] as? String) ?? ""
                )
                completion(.success(metadata))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchBackupPayload(completion: @escaping (Result<String?, Error>) -> Void) {
        fetchRecord { result in
            switch result {
            case .success(let record):
                guard let record = record,
                      let asset = record[self.fieldPayload] as? CKAsset,
                      let fileURL = asset.fileURL else {
                    completion(.success(nil))
                    return
                }
                do {
                    let payload = try String(contentsOf: fileURL, encoding: .utf8)
                    completion(.success(payload))
                } catch {
                    completion(.failure(CloudKitBackupError(
                        code: "READ_ASSET_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    )))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helpers

    /// Fetches the single backup record, returning nil when it doesn't exist yet.
    private func fetchRecord(completion: @escaping (Result<CKRecord?, Error>) -> Void) {
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                if let ckError = error as? CKError, ckError.code == .unknownItem {
                    completion(.success(nil))
                    return
                }
                completion(.failure(CloudKitBackupError(
                    code: "FETCH_FAILED",
                    message: error.localizedDescription,
                    details: nil
                )))
                return
            }
            completion(.success(record))
        }
    }

    private func mapAccountStatus(_ status: CKAccountStatus) -> IcloudAccountStatus {
        // Note: `.temporarilyUnavailable` (iOS 15+) is intentionally not matched
        // explicitly so this compiles for the iOS 13 deployment target; it falls
        // through to `@unknown default`.
        switch status {
        case .available:
            return .available
        case .noAccount:
            return .noAccount
        case .restricted:
            return .restricted
        case .couldNotDetermine:
            return .couldNotDetermine
        @unknown default:
            return .couldNotDetermine
        }
    }
}
