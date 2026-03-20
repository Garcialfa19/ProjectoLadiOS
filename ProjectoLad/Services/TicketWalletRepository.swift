import FirebaseFirestore
import Foundation

protocol TicketWalletRepositoryProtocol {
    func listenForTickets(userID: String, onChange: @escaping (Result<[TicketPass], Error>) -> Void) -> ListenerRegistration
    func createTicket(for userID: String, userEmail: String?, event: Event, tier: TicketTier) async throws -> TicketPass
    func markTicketAsUsed(ticketID: String, scannerID: String?) async throws
    func fetchTicketByQRToken(_ qrToken: String) async throws -> TicketPass?
}

struct FirestoreTicketWalletRepository: TicketWalletRepositoryProtocol {
    private let database: Firestore
    private let ticketsCollection = "tickets"
    private let walletsCollection = "wallets"
    private let redemptionStore: TicketRedemptionStoreProtocol

    init(
        database: Firestore = Firestore.firestore(),
        redemptionStore: TicketRedemptionStoreProtocol? = nil
    ) {
        self.database = database
        self.redemptionStore = redemptionStore ?? FirestoreTicketRedemptionStore(database: database)
    }

    func listenForTickets(userID: String, onChange: @escaping (Result<[TicketPass], Error>) -> Void) -> ListenerRegistration {
        database.collection(ticketsCollection)
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot else {
                    onChange(.success([]))
                    return
                }

                do {
                    let tickets = try snapshot.documents
                        .map(TicketPass.init(document:))
                        .sorted(by: { $0.purchasedAt > $1.purchasedAt })
                    onChange(.success(tickets))
                } catch {
                    onChange(.failure(error))
                }
            }
    }

    func createTicket(for userID: String, userEmail: String?, event: Event, tier: TicketTier) async throws -> TicketPass {
        let ticketID = UUID().uuidString.lowercased()
        let walletDocument = database.collection(walletsCollection)
            .document(userID)
            .collection(ticketsCollection)
            .document(ticketID)
        let legacyDocument = database.collection(ticketsCollection).document(ticketID)
        let purchasedAt = Date()
        let qrToken = UUID().uuidString.lowercased()
        let qrPayload = "nightlifepass://ticket/\(ticketID)?wallet=\(userID)&event=\(event.id)&tier=\(tier.code)&token=\(qrToken)"

        let payload: [String: Any] = [
            "walletID": userID,
            "userID": userID,
            "userEmail": userEmail as Any,
            "eventID": event.id,
            "eventTitle": event.title,
            "venueName": event.venueName,
            "eventStartDate": Timestamp(date: event.startDate),
            "tierCode": tier.code,
            "tierName": tier.name,
            "price": tier.price,
            "currencyCode": tier.currencyCode,
            "qrToken": qrToken,
            "qrPayload": qrPayload,
            "status": TicketPassStatus.active.rawValue,
            "purchasedAt": Timestamp(date: purchasedAt),
            "usedAt": NSNull(),
            "scannedBy": NSNull(),
            "appleWalletPassURL": NSNull()
        ]

        do {
            try await walletDocument.setData(payload)
        } catch {
            if !isPermissionDenied(error) {
                throw error
            }
        }

        try await legacyDocument.setData(payload)

        return TicketPass(
            id: ticketID,
            userID: userID,
            userEmail: userEmail,
            walletID: userID,
            eventID: event.id,
            eventTitle: event.title,
            venueName: event.venueName,
            eventStartDate: event.startDate,
            tierCode: tier.code,
            tierName: tier.name,
            price: tier.price,
            currencyCode: tier.currencyCode,
            qrToken: qrToken,
            qrPayload: qrPayload,
            appleWalletPassURL: nil,
            status: .active,
            purchasedAt: purchasedAt,
            usedAt: nil,
            scannedBy: nil
        )
    }

    func markTicketAsUsed(ticketID: String, scannerID: String?) async throws {
        do {
            try await redemptionStore.markTicketAsUsed(ticketID: ticketID, scannerID: scannerID)
        } catch let error as SharedTicketRedemptionError {
            switch error {
            case .ticketNotFound:
                throw TicketWalletRepositoryError.ticketNotFound
            case .ticketAlreadyUsed:
                throw TicketWalletRepositoryError.ticketAlreadyUsed
            }
        }
    }

    func fetchTicketByQRToken(_ qrToken: String) async throws -> TicketPass? {
        let querySnapshot = try await database.collectionGroup(ticketsCollection)
            .whereField("qrToken", isEqualTo: qrToken)
            .limit(to: 1)
            .getDocuments()

        guard let document = querySnapshot.documents.first else {
            return nil
        }

        return try TicketPass(document: document)
    }
}

private extension FirestoreTicketWalletRepository {
    func isPermissionDenied(_ error: Error) -> Bool {
        let nsError = error as NSError
        return FirestoreErrorCode.Code(rawValue: nsError.code) == .permissionDenied
    }
}

private extension TicketPass {
    init(document: QueryDocumentSnapshot) throws {
        let data = document.data()

        guard
            let userID = data["userID"] as? String,
            let eventID = data["eventID"] as? String,
            let eventTitle = data["eventTitle"] as? String,
            let venueName = data["venueName"] as? String,
            let eventStartDate = (data["eventStartDate"] as? Timestamp)?.dateValue(),
            let tierCode = data["tierCode"] as? String,
            let tierName = data["tierName"] as? String,
            let price = data["price"] as? Double,
            let currencyCode = data["currencyCode"] as? String,
            let qrToken = data["qrToken"] as? String,
            let qrPayload = data["qrPayload"] as? String,
            let statusRawValue = data["status"] as? String,
            let status = TicketPassStatus(rawValue: statusRawValue),
            let purchasedAt = (data["purchasedAt"] as? Timestamp)?.dateValue()
        else {
            throw TicketWalletMappingError.invalidTicket(documentID: document.documentID)
        }

        self.init(
            id: document.documentID,
            userID: userID,
            userEmail: data["userEmail"] as? String,
            walletID: data["walletID"] as? String ?? userID,
            eventID: eventID,
            eventTitle: eventTitle,
            venueName: venueName,
            eventStartDate: eventStartDate,
            tierCode: tierCode,
            tierName: tierName,
            price: price,
            currencyCode: currencyCode,
            qrToken: qrToken,
            qrPayload: qrPayload,
            appleWalletPassURL: (data["appleWalletPassURL"] as? String).flatMap(URL.init(string:)),
            status: status,
            purchasedAt: purchasedAt,
            usedAt: (data["usedAt"] as? Timestamp)?.dateValue(),
            scannedBy: data["scannedBy"] as? String
        )
    }
}

private enum TicketWalletMappingError: LocalizedError {
    case invalidTicket(documentID: String)

    var errorDescription: String? {
        switch self {
        case .invalidTicket(let documentID):
            return "Ticket document \(documentID) is missing required fields."
        }
    }
}

enum TicketWalletRepositoryError: LocalizedError {
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
