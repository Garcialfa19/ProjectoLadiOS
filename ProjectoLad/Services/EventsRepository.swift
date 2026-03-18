import FirebaseFirestore
import Foundation

protocol EventsRepositoryProtocol {
    func listenForEvents(onChange: @escaping (Result<[Event], Error>) -> Void) -> ListenerRegistration
}

struct FirestoreEventsRepository: EventsRepositoryProtocol {
    private let database: Firestore

    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    func listenForEvents(onChange: @escaping (Result<[Event], Error>) -> Void) -> ListenerRegistration {
        database.collection("events")
            .order(by: "startDate", descending: false)
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
                    let events = try snapshot.documents.compactMap { document in
                        try Event(document: document)
                    }
                    onChange(.success(events))
                } catch {
                    onChange(.failure(error))
                }
            }
    }
}

private extension Event {
    init(document: QueryDocumentSnapshot) throws {
        let data = document.data()

        guard
            let title = data["title"] as? String,
            let subtitle = data["subtitle"] as? String,
            let summary = data["summary"] as? String,
            let heroSymbol = data["heroSymbol"] as? String,
            let badgeText = data["badgeText"] as? String,
            let hostName = data["hostName"] as? String,
            let venueName = data["venueName"] as? String,
            let neighborhood = data["neighborhood"] as? String,
            let address = data["address"] as? String,
            let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
            let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
            let priceFrom = data["priceFrom"] as? Double,
            let currencyCode = data["currencyCode"] as? String,
            let description = data["description"] as? String,
            let agePolicy = data["agePolicy"] as? String,
            let dressCode = data["dressCode"] as? String,
            let parkingInfo = data["parkingInfo"] as? String,
            let musicGenres = data["musicGenres"] as? [String],
            let lineup = data["lineup"] as? [String],
            let amenities = data["amenities"] as? [String],
            let statusRawValue = data["status"] as? String,
            let status = EventStatus(rawValue: statusRawValue),
            let isFeatured = data["isFeatured"] as? Bool,
            let locationMap = data["location"] as? [String: Double],
            let latitude = locationMap["latitude"],
            let longitude = locationMap["longitude"],
            let tierMaps = data["ticketTiers"] as? [[String: Any]]
        else {
            throw FirestoreMappingError.invalidEventDocument(documentID: document.documentID)
        }

        let ticketTiers = try tierMaps.map(TicketTier.init(dictionary:))

        self.init(
            documentID: document.documentID,
            title: title,
            subtitle: subtitle,
            summary: summary,
            heroSymbol: heroSymbol,
            badgeText: badgeText,
            hostName: hostName,
            venueName: venueName,
            neighborhood: neighborhood,
            address: address,
            startDate: startDate,
            endDate: endDate,
            doorsOpen: (data["doorsOpen"] as? Timestamp)?.dateValue(),
            priceFrom: priceFrom,
            currencyCode: currencyCode,
            description: description,
            agePolicy: agePolicy,
            dressCode: dressCode,
            parkingInfo: parkingInfo,
            musicGenres: musicGenres,
            lineup: lineup,
            amenities: amenities,
            status: status,
            isFeatured: isFeatured,
            capacity: data["capacity"] as? Int,
            ticketsRemaining: data["ticketsRemaining"] as? Int,
            location: EventLocation(latitude: latitude, longitude: longitude),
            ticketTiers: ticketTiers
        )
    }
}

private extension TicketTier {
    init(dictionary: [String: Any]) throws {
        guard
            let code = dictionary["code"] as? String,
            let name = dictionary["name"] as? String,
            let price = dictionary["price"] as? Double,
            let currencyCode = dictionary["currencyCode"] as? String,
            let perks = dictionary["perks"] as? [String],
            let isRecommended = dictionary["isRecommended"] as? Bool
        else {
            throw FirestoreMappingError.invalidTicketTier
        }

        self.init(
            code: code,
            name: name,
            price: price,
            currencyCode: currencyCode,
            perks: perks,
            remainingInventory: dictionary["remainingInventory"] as? Int,
            isRecommended: isRecommended
        )
    }
}

private enum FirestoreMappingError: LocalizedError {
    case invalidEventDocument(documentID: String)
    case invalidTicketTier

    var errorDescription: String? {
        switch self {
        case .invalidEventDocument(let documentID):
            return "Event document \(documentID) is missing required fields."
        case .invalidTicketTier:
            return "A ticket tier entry is missing required fields."
        }
    }
}
