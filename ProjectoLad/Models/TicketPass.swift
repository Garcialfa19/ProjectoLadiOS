import Foundation

struct TicketPass: Identifiable, Hashable {
    let id: String
    let userID: String
    let userEmail: String?
    let eventID: String
    let eventTitle: String
    let venueName: String
    let eventStartDate: Date
    let tierCode: String
    let tierName: String
    let price: Double
    let currencyCode: String
    let qrPayload: String
    let status: TicketPassStatus
    let purchasedAt: Date
    let usedAt: Date?

    var priceText: String {
        price.formatted(.currency(code: currencyCode))
    }

    var purchaseDateText: String {
        purchasedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    var eventDateText: String {
        eventStartDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
    }

    var statusTitle: String {
        status.displayTitle
    }
}

enum TicketPassStatus: String, Hashable {
    case active
    case used
    case invalidated

    var displayTitle: String {
        switch self {
        case .active:
            return "Active"
        case .used:
            return "Used"
        case .invalidated:
            return "Invalid"
        }
    }
}
