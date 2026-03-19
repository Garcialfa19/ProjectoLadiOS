import Foundation

struct ScannerTicket: Equatable {
    let id: String
    let walletID: String
    let eventID: String
    let tierCode: String
    let qrToken: String
    let status: TicketPassStatus
    let usedAt: Date?
    let scannedBy: String?
}

extension ScannerTicket {
    init(record: SharedTicketRecord) {
        self.init(
            id: record.id,
            walletID: record.walletID,
            eventID: record.eventID,
            tierCode: record.tierCode,
            qrToken: record.qrToken,
            status: record.status,
            usedAt: record.usedAt,
            scannedBy: record.scannedBy
        )
    }
}
