import FirebaseFirestore
import Foundation

protocol TicketWalletRepositoryProtocol {
    func listenForTickets(userID: String, onChange: @escaping (Result<[TicketPass], Error>) -> Void) -> ListenerRegistration
    func createTicket(for userID: String, userEmail: String?, event: Event, tier: TicketTier) async throws -> TicketPass
}

struct FirestoreTicketWalletRepository: TicketWalletRepositoryProtocol {
    private let database: Firestore

    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    func listenForTickets(userID: String, onChange: @escaping (Result<[TicketPass], Error>) -> Void) -> ListenerRegistration {
        database.collection("tickets")
            .whereField("userID", isEqualTo: userID)
            .order(by: "purchasedAt", descending: true)
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
                    let tickets = try snapshot.documents.map(TicketPass.init(document:))
                    onChange(.success(tickets))
                } catch {
                    onChange(.failure(error))
                }
            }
    }

    func createTicket(for userID: String, userEmail: String?, event: Event, tier: TicketTier) async throws -> TicketPass {
        let document = database.collection("tickets").document()
        let purchasedAt = Date()
        let qrPayload = "nightlifepass://ticket/\(document.documentID)?user=\(userID)&event=\(event.id)&tier=\(tier.code)&token=\(UUID().uuidString)"

        let payload: [String: Any] = [
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
            "qrPayload": qrPayload,
            "status": TicketPassStatus.active.rawValue,
            "purchasedAt": Timestamp(date: purchasedAt),
            "usedAt": NSNull()
        ]

        try await document.setData(payload)

        return TicketPass(
            id: document.documentID,
            userID: userID,
            userEmail: userEmail,
            eventID: event.id,
            eventTitle: event.title,
            venueName: event.venueName,
            eventStartDate: event.startDate,
            tierCode: tier.code,
            tierName: tier.name,
            price: tier.price,
            currencyCode: tier.currencyCode,
            qrPayload: qrPayload,
            status: .active,
            purchasedAt: purchasedAt,
            usedAt: nil
        )
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
            eventID: eventID,
            eventTitle: eventTitle,
            venueName: venueName,
            eventStartDate: eventStartDate,
            tierCode: tierCode,
            tierName: tierName,
            price: price,
            currencyCode: currencyCode,
            qrPayload: qrPayload,
            status: status,
            purchasedAt: purchasedAt,
            usedAt: (data["usedAt"] as? Timestamp)?.dateValue()
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
