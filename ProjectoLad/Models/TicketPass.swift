import Foundation

struct TicketPass: Identifiable, Hashable {
    let id: String
    let userID: String
    let userEmail: String?
    let walletID: String
    let eventID: String
    let eventTitle: String
    let venueName: String
    let eventStartDate: Date
    let tierCode: String
    let tierName: String
    let price: Double
    let currencyCode: String
    let qrToken: String
    let qrPayload: String
    let appleWalletPassURL: URL?
    let status: TicketPassStatus
    let purchasedAt: Date
    let usedAt: Date?
    let scannedBy: String?

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

    var shortCode: String {
        String(id.suffix(8)).uppercased()
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
