import FirebaseFirestore
import Foundation

protocol ScannerTicketRepositoryProtocol {
    func fetchTicketByQRToken(_ qrToken: String) async throws -> ScannerTicket?
    func redeemTicket(ticketID: String, scannerID: String) async throws
}

enum ScannerTicketRepositoryError: LocalizedError, Equatable {
    case permissionDenied
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied."
        case .network:
            return "Network unavailable."
        case .unknown:
            return "Something went wrong while redeeming."
        }
    }
}

struct ScannerTicketRepository: ScannerTicketRepositoryProtocol {
    private let store: TicketRedemptionStoreProtocol

    init(store: TicketRedemptionStoreProtocol = FirestoreTicketRedemptionStore()) {
        self.store = store
    }

    func fetchTicketByQRToken(_ qrToken: String) async throws -> ScannerTicket? {
        do {
            guard let record = try await store.fetchTicketByQRToken(qrToken) else {
                return nil
            }
            return ScannerTicket(record: record)
        } catch {
            throw mapError(error)
        }
    }

    func redeemTicket(ticketID: String, scannerID: String) async throws {
        do {
            try await store.markTicketAsUsed(ticketID: ticketID, scannerID: scannerID)
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> Error {
        if let storeError = error as? SharedTicketRedemptionError {
            return storeError
        }

        let nsError = error as NSError
        if nsError.domain == FirestoreErrorDomain {
            switch nsError.code {
            case FirestoreErrorCode.permissionDenied.rawValue:
                return ScannerTicketRepositoryError.permissionDenied
            case FirestoreErrorCode.unavailable.rawValue:
                return ScannerTicketRepositoryError.network
            default:
                break
            }
        }
        return ScannerTicketRepositoryError.unknown
    }
}
