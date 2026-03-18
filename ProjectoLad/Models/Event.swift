
import Foundation
import CoreLocation

struct Event: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let dateText: String
    let timeText: String
    let basePriceText: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let ticketTiers: [TicketTier]
    let badgeText: String
    let hostName: String

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TicketTier: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let priceText: String
    let perks: String
}

extension Event {
    static let sampleEvents: [Event] = [
        Event(
            title: "Cerclé Night Sessions",
            subtitle: "Immersive visuals + curated DJ lineup",
            imageName: "music.mic.circle.fill",
            dateText: "Fri, Mar 20",
            timeText: "9:00 PM",
            basePriceText: "$15",
            description: "A premium nightlife experience with a cinematic visual setup, guest DJs, early-access perks, and VIP lounge options inspired by modern ticketing apps.",
            coordinate: CLLocationCoordinate2D(latitude: 9.935, longitude: -84.091),
            address: "Downtown San José, Costa Rica",
            ticketTiers: [
                TicketTier(name: "General", priceText: "$15", perks: "Standard entry"),
                TicketTier(name: "Fast Pass", priceText: "$25", perks: "Priority line"),
                TicketTier(name: "VIP", priceText: "$50", perks: "VIP area + welcome drink")
            ],
            badgeText: "Trending",
            hostName: "Hosted by Midnight Social"
        ),
        Event(
            title: "Unveiled Rooftop",
            subtitle: "Sunset house set + premium bottle service",
            imageName: "sparkles.rectangle.stack.fill",
            dateText: "Sat, Mar 21",
            timeText: "7:30 PM",
            basePriceText: "$20",
            description: "Open-air rooftop party with premium views, elevated cocktails, guest artists, and tiered seating designed for both casual guests and high-value bookings.",
            coordinate: CLLocationCoordinate2D(latitude: 10.000, longitude: -84.116),
            address: "Escazú, San José, Costa Rica",
            ticketTiers: [
                TicketTier(name: "General", priceText: "$20", perks: "Standard entry"),
                TicketTier(name: "Premium", priceText: "$35", perks: "2-for-1 cocktail voucher"),
                TicketTier(name: "VIP Table", priceText: "$120", perks: "Reserved table + bottle credit")
            ],
            badgeText: "Limited",
            hostName: "Hosted by NightLife Pass"
        ),
        Event(
            title: "After Dark Throwback",
            subtitle: "Classic hits, modern production",
            imageName: "party.popper.fill",
            dateText: "Thu, Mar 26",
            timeText: "8:00 PM",
            basePriceText: "$10",
            description: "A nostalgic party with a sleek digital ticketing experience, sharable event art, themed visuals, and a fast, mobile-first entry flow.",
            coordinate: CLLocationCoordinate2D(latitude: 9.928, longitude: -84.090),
            address: "Barrio Escalante, San José, Costa Rica",
            ticketTiers: [
                TicketTier(name: "Early Bird", priceText: "$10", perks: "Discounted entry"),
                TicketTier(name: "General", priceText: "$15", perks: "Standard entry"),
                TicketTier(name: "VIP", priceText: "$40", perks: "Lounge access + merch")
            ],
            badgeText: "Popular",
            hostName: "Hosted by Midnight Social"
        )
    ]
}
