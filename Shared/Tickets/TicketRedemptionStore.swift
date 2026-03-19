import FirebaseFirestore
import Foundation

struct SharedTicketRecord: Equatable {
    let id: String
    let userID: String
    let walletID: String
    let eventID: String
    let tierCode: String
    let qrToken: String
    let status: TicketPassStatus
    let usedAt: Date?
    let scannedBy: String?
}

protocol TicketRedemptionStoreProtocol {
    func fetchTicketByQRToken(_ qrToken: String) async throws -> SharedTicketRecord?
    func markTicketAsUsed(ticketID: String, scannerID: String?) async throws
}

enum SharedTicketRedemptionError: LocalizedError {
    case ticketNotFound
    case ticketAlreadyUsed

    var errorDescription: String? {
        switch self {
        case .ticketNotFound:
            return "Ticket was not found."
        case .ticketAlreadyUsed:
            return "Ticket is no longer active."
        }
    }
}

struct FirestoreTicketRedemptionStore: TicketRedemptionStoreProtocol {
    private let database: Firestore
    private let ticketsCollection = "tickets"

    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    func fetchTicketByQRToken(_ qrToken: String) async throws -> SharedTicketRecord? {
        let querySnapshot = try await database.collectionGroup(ticketsCollection)
            .whereField("qrToken", isEqualTo: qrToken)
            .limit(to: 1)
            .getDocuments()

        guard let document = querySnapshot.documents.first else {
            return nil
        }

        return try SharedTicketRecord(document: document)
    }

    func markTicketAsUsed(ticketID: String, scannerID: String?) async throws {
        let querySnapshot = try await database.collectionGroup(ticketsCollection)
            .whereField(FieldPath.documentID(), isEqualTo: ticketID)
            .limit(to: 1)
            .getDocuments()

        guard let reference = querySnapshot.documents.first?.reference else {
            throw SharedTicketRedemptionError.ticketNotFound
        }

        let _ = try await database.runTransaction { transaction, errorPointer -> Any? in
            guard let snapshot = try? transaction.getDocument(reference) else {
                errorPointer?.pointee = SharedTicketRedemptionError.ticketNotFound as NSError
                return nil
            }

            let statusRawValue = snapshot.get("status") as? String ?? TicketPassStatus.invalidated.rawValue
            guard statusRawValue == TicketPassStatus.active.rawValue else {
                errorPointer?.pointee = SharedTicketRedemptionError.ticketAlreadyUsed as NSError
                return nil
            }

            transaction.updateData([
                "status": TicketPassStatus.used.rawValue,
                "usedAt": Timestamp(date: Date()),
                "scannedBy": scannerID as Any
            ], forDocument: reference)

            return nil
        }
    }
}

private extension SharedTicketRecord {
    init(document: QueryDocumentSnapshot) throws {
        let data = document.data()

        guard
            let userID = data["userID"] as? String,
            let eventID = data["eventID"] as? String,
            let tierCode = data["tierCode"] as? String,
            let qrToken = data["qrToken"] as? String,
            let statusRawValue = data["status"] as? String,
            let status = TicketPassStatus(rawValue: statusRawValue)
        else {
            throw SharedTicketRedemptionError.ticketNotFound
        }

        self.init(
            id: document.documentID,
            userID: userID,
            walletID: data["walletID"] as? String ?? userID,
            eventID: eventID,
            tierCode: tierCode,
            qrToken: qrToken,
            status: status,
            usedAt: (data["usedAt"] as? Timestamp)?.dateValue(),
            scannedBy: data["scannedBy"] as? String
        )
    }
}
