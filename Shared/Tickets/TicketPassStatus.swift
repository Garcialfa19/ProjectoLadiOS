import Foundation

enum TicketPassStatus: String, Hashable {
    case active
    case used
    case invalidated

    var displayTitle: String {
        switch self {
        case .active: "Active"
        case .used: "Used"
        case .invalidated: "Invalid"
        }
    }
}
