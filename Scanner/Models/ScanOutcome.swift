import Foundation

enum ScanOutcome: Equatable {
    case valid(ticketID: String)
    case alreadyUsed(ticketID: String)
    case invalid(reason: String)

    var title: String {
        switch self {
        case .valid:
            return "VALID"
        case .alreadyUsed:
            return "ALREADY USED"
        case .invalid:
            return "INVALID"
        }
    }

    var detail: String {
        switch self {
        case .valid(let ticketID):
            return "Ticket \(ticketID) redeemed."
        case .alreadyUsed(let ticketID):
            return "Ticket \(ticketID) has already been redeemed."
        case .invalid(let reason):
            return reason
        }
    }

    var isSuccess: Bool {
        if case .valid = self { return true }
        return false
    }
}
