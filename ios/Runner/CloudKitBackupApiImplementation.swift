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

    func accountStatus() async throws -> IcloudAccountStatus {
        do {
            let status = try await container.accountStatus()
            return mapAccountStatus(status)
        } catch {
            throw CloudKitBackupError(
                code: "ACCOUNT_STATUS_ERROR",
                message: error.localizedDescription,
                details: nil
            )
        }
    }

    func saveBackup(
        jsonPayload: String,
        deckCount: Int64,
        cardCount: Int64,
        version: String
    ) async throws {
        // Write the payload to a temporary file for the CKAsset.
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck_backup_\(UUID().uuidString).json")
        do {
            try jsonPayload.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            throw CloudKitBackupError(
                code: "WRITE_TEMP_FAILED",
                message: error.localizedDescription,
                details: nil
            )
        }
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let record = try await fetchRecord()
            ?? CKRecord(recordType: recordType, recordID: recordID)

        let deviceName = await MainActor.run { UIDevice.current.name }
        record[fieldPayload] = CKAsset(fileURL: tempURL)
        record[fieldUpdatedAt] = Date() as CKRecordValue
        record[fieldDeviceName] = deviceName as CKRecordValue
        record[fieldDeckCount] = NSNumber(value: deckCount)
        record[fieldCardCount] = NSNumber(value: cardCount)
        record[fieldVersion] = version as CKRecordValue

        do {
            // Overwrite the server record unconditionally — one backup, no history.
            let (saveResults, _) = try await privateDatabase.modifyRecords(
                saving: [record],
                deleting: [],
                savePolicy: .allKeys
            )
            // Per-record failures are reported in the results, not thrown.
            if case .failure(let error) = saveResults[record.recordID] {
                throw error
            }
        } catch {
            throw CloudKitBackupError(
                code: "SAVE_FAILED",
                message: error.localizedDescription,
                details: nil
            )
        }
    }

    func fetchBackupMetadata() async throws -> BackupMetadata? {
        guard let record = try await fetchRecord() else { return nil }
        let updatedAt = (record[fieldUpdatedAt] as? Date) ?? Date()
        return BackupMetadata(
            updatedAtEpochMs: Int64(updatedAt.timeIntervalSince1970 * 1000),
            deviceName: (record[fieldDeviceName] as? String) ?? "",
            deckCount: (record[fieldDeckCount] as? NSNumber)?.int64Value ?? 0,
            cardCount: (record[fieldCardCount] as? NSNumber)?.int64Value ?? 0,
            version: (record[fieldVersion] as? String) ?? ""
        )
    }

    func fetchBackupPayload() async throws -> String? {
        guard let record = try await fetchRecord(),
              let asset = record[fieldPayload] as? CKAsset,
              let fileURL = asset.fileURL else {
            return nil
        }
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw CloudKitBackupError(
                code: "READ_ASSET_FAILED",
                message: error.localizedDescription,
                details: nil
            )
        }
    }

    // MARK: - Helpers

    /// Fetches the single backup record, returning nil when it doesn't exist yet.
    private func fetchRecord() async throws -> CKRecord? {
        do {
            return try await privateDatabase.record(for: recordID)
        } catch let ckError as CKError where ckError.code == .unknownItem {
            return nil
        } catch {
            throw CloudKitBackupError(
                code: "FETCH_FAILED",
                message: error.localizedDescription,
                details: nil
            )
        }
    }

    private func mapAccountStatus(_ status: CKAccountStatus) -> IcloudAccountStatus {
        switch status {
        case .available:
            return .available
        case .noAccount:
            return .noAccount
        case .restricted:
            return .restricted
        case .couldNotDetermine, .temporarilyUnavailable:
            return .couldNotDetermine
        @unknown default:
            return .couldNotDetermine
        }
    }
}
