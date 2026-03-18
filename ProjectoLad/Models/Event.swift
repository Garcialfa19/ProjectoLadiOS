import CoreLocation
import Foundation

struct Event: Codable, Identifiable, Hashable {
    var documentID: String
    var title: String
    var subtitle: String
    var summary: String
    var heroSymbol: String
    var badgeText: String
    var hostName: String
    var venueName: String
    var neighborhood: String
    var address: String
    var startDate: Date
    var endDate: Date
    var doorsOpen: Date?
    var priceFrom: Double
    var currencyCode: String
    var description: String
    var agePolicy: String
    var dressCode: String
    var parkingInfo: String
    var musicGenres: [String]
    var lineup: [String]
    var amenities: [String]
    var status: EventStatus
    var isFeatured: Bool
    var capacity: Int?
    var ticketsRemaining: Int?
    var location: EventLocation
    var ticketTiers: [TicketTier]

    var id: String {
        documentID
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var priceFromText: String {
        priceFrom.formatted(.currency(code: currencyCode))
    }

    var startsDayText: String {
        startDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var startTimeText: String {
        startDate.formatted(.dateTime.hour().minute())
    }

    var endTimeText: String {
        endDate.formatted(.dateTime.hour().minute())
    }

    var timeRangeText: String {
        "\(startTimeText) - \(endTimeText)"
    }

    var doorsOpenText: String {
        guard let doorsOpen else { return "Doors with first entry window" }
        return doorsOpen.formatted(.dateTime.hour().minute())
    }

    var locationSummary: String {
        "\(venueName), \(neighborhood)"
    }

    var availabilityText: String {
        guard let ticketsRemaining else { return "Availability updates live" }

        switch ticketsRemaining {
        case ..<1:
            return "Sold out"
        case 1..<25:
            return "\(ticketsRemaining) tickets left"
        default:
            return "\(ticketsRemaining) tickets available"
        }
    }

    var sortedTicketTiers: [TicketTier] {
        ticketTiers.sorted { $0.price < $1.price }
    }

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum EventStatus: String, Codable, Hashable, CaseIterable {
    case scheduled
    case soldOut
    case cancelled

    var displayTitle: String {
        switch self {
        case .scheduled:
            return "Scheduled"
        case .soldOut:
            return "Sold Out"
        case .cancelled:
            return "Cancelled"
        }
    }
}

struct EventLocation: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct TicketTier: Codable, Identifiable, Hashable {
    var code: String
    var name: String
    var price: Double
    var currencyCode: String
    var perks: [String]
    var remainingInventory: Int?
    var isRecommended: Bool

    var id: String { code }

    var priceText: String {
        price.formatted(.currency(code: currencyCode))
    }

    var perksSummary: String {
        perks.joined(separator: " • ")
    }

    var inventoryText: String {
        guard let remainingInventory else { return "Inventory managed in Firestore" }
        if remainingInventory == 0 { return "Unavailable" }
        if remainingInventory < 15 { return "\(remainingInventory) left" }
        return "\(remainingInventory) available"
    }
}

extension Event {
    static let sampleEvents: [Event] = [
        Event(
            documentID: "sample-cerclenight",
            title: "Cerclé Night Sessions",
            subtitle: "Immersive visuals and a carefully timed DJ journey",
            summary: "A premium Friday headline set with a calmer, native-style booking flow and clear guest details.",
            heroSymbol: "waveform.badge.magnifyingglass",
            badgeText: "Featured",
            hostName: "Midnight Social",
            venueName: "Cercle Hall",
            neighborhood: "Downtown San Jose",
            address: "Avenida Central 124, San Jose, Costa Rica",
            startDate: sampleDate(year: 2026, month: 3, day: 20, hour: 21, minute: 0),
            endDate: sampleDate(year: 2026, month: 3, day: 21, hour: 2, minute: 0),
            doorsOpen: sampleDate(year: 2026, month: 3, day: 20, hour: 20, minute: 15),
            priceFrom: 15,
            currencyCode: "USD",
            description: "Designed for guests who want all the practical details before buying: lineup, arrival window, dress expectations, and live ticket availability.",
            agePolicy: "18+ with valid ID at entry",
            dressCode: "Night out attire encouraged. No beachwear or sports jerseys.",
            parkingInfo: "Valet at venue entrance. Limited self-parking two blocks away.",
            musicGenres: ["Melodic house", "Afro house", "Visual performance"],
            lineup: ["Sofi Vega", "Milo Aster", "Closing visual set by Studio Norte"],
            amenities: ["Express check-in", "VIP lounge", "Welcome drink", "Apple Wallet pass"],
            status: .scheduled,
            isFeatured: true,
            capacity: 320,
            ticketsRemaining: 46,
            location: EventLocation(latitude: 9.935, longitude: -84.091),
            ticketTiers: [
                TicketTier(code: "general", name: "General", price: 15, currencyCode: "USD", perks: ["Standard entry"], remainingInventory: 30, isRecommended: false),
                TicketTier(code: "fast-pass", name: "Fast Pass", price: 25, currencyCode: "USD", perks: ["Priority line", "Dedicated entry lane"], remainingInventory: 10, isRecommended: true),
                TicketTier(code: "vip", name: "VIP", price: 50, currencyCode: "USD", perks: ["VIP lounge", "Welcome drink", "Reserved host check-in"], remainingInventory: 6, isRecommended: false)
            ]
        ),
        Event(
            documentID: "sample-unveiled",
            title: "Unveiled Rooftop",
            subtitle: "Sunset house set with table-first hospitality",
            summary: "A rooftop evening optimized for premium groups, clearer table options, and concise event planning.",
            heroSymbol: "sun.max",
            badgeText: "Limited",
            hostName: "NightLife Pass",
            venueName: "Unveiled Rooftop",
            neighborhood: "Escazu",
            address: "Skyline Tower, Escazu, San Jose, Costa Rica",
            startDate: sampleDate(year: 2026, month: 3, day: 21, hour: 19, minute: 30),
            endDate: sampleDate(year: 2026, month: 3, day: 22, hour: 1, minute: 0),
            doorsOpen: sampleDate(year: 2026, month: 3, day: 21, hour: 18, minute: 45),
            priceFrom: 20,
            currencyCode: "USD",
            description: "The listing emphasizes arrival timing, bottle-service positioning, and how much inventory remains by tier so guests can decide quickly.",
            agePolicy: "21+ after 10 PM",
            dressCode: "Smart casual. Dress shoes and elevated evening wear preferred.",
            parkingInfo: "Underground paid parking in Skyline Tower.",
            musicGenres: ["Sunset house", "Disco edits", "Vocal deep house"],
            lineup: ["Luna Sol", "Mar de Oro", "Rooftop close by Casa Color"],
            amenities: ["Reserved table support", "Bottle service", "Outdoor terrace", "Photo moment"],
            status: .scheduled,
            isFeatured: true,
            capacity: 180,
            ticketsRemaining: 18,
            location: EventLocation(latitude: 10.000, longitude: -84.116),
            ticketTiers: [
                TicketTier(code: "general", name: "General", price: 20, currencyCode: "USD", perks: ["Standard entry"], remainingInventory: 8, isRecommended: false),
                TicketTier(code: "premium", name: "Premium", price: 35, currencyCode: "USD", perks: ["Dedicated bar lane", "Two welcome cocktails"], remainingInventory: 6, isRecommended: true),
                TicketTier(code: "vip-table", name: "VIP Table", price: 120, currencyCode: "USD", perks: ["Reserved table", "Bottle credit", "Host escort"], remainingInventory: 4, isRecommended: false)
            ]
        ),
        Event(
            documentID: "sample-afterdark",
            title: "After Dark Throwback",
            subtitle: "Classic hits with polished production and easy planning",
            summary: "A more casual event card that still surfaces entry policy, vibe, and what is included with each pass.",
            heroSymbol: "music.note.house",
            badgeText: "Popular",
            hostName: "Midnight Social",
            venueName: "Barrio Club",
            neighborhood: "Barrio Escalante",
            address: "Calle 33, Barrio Escalante, San Jose, Costa Rica",
            startDate: sampleDate(year: 2026, month: 3, day: 26, hour: 20, minute: 0),
            endDate: sampleDate(year: 2026, month: 3, day: 27, hour: 1, minute: 30),
            doorsOpen: sampleDate(year: 2026, month: 3, day: 26, hour: 19, minute: 15),
            priceFrom: 10,
            currencyCode: "USD",
            description: "A nostalgia-driven night with practical guest information up front, including ID requirements, arrival guidance, and tier benefits.",
            agePolicy: "18+ only",
            dressCode: "Casual night-out attire",
            parkingInfo: "Street parking nearby. Rideshare drop-off recommended.",
            musicGenres: ["2000s hits", "Throwback pop", "Sing-along edits"],
            lineup: ["DJ Vale", "DJ Roca", "Midnight sing-along set"],
            amenities: ["Fast mobile check-in", "Merch pop-up", "Photo wall"],
            status: .scheduled,
            isFeatured: false,
            capacity: 260,
            ticketsRemaining: 102,
            location: EventLocation(latitude: 9.928, longitude: -84.090),
            ticketTiers: [
                TicketTier(code: "early-bird", name: "Early Bird", price: 10, currencyCode: "USD", perks: ["Discounted entry"], remainingInventory: 0, isRecommended: false),
                TicketTier(code: "general", name: "General", price: 15, currencyCode: "USD", perks: ["Standard entry"], remainingInventory: 74, isRecommended: true),
                TicketTier(code: "vip", name: "VIP", price: 40, currencyCode: "USD", perks: ["Lounge access", "Merch item"], remainingInventory: 28, isRecommended: false)
            ]
        )
    ]

    private static func sampleDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: DateComponents(
            timeZone: TimeZone(identifier: "America/Costa_Rica"),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )) ?? .now
    }
}
