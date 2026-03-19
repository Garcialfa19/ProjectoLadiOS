import Foundation
import Testing
@testable import ProjectoLad

@MainActor
struct ScannerSessionViewModelTests {
    @Test func activeTicketRedeemsAsValid() async {
        let repository = MockScannerTicketRepository(
            fetchedTicket: ScannerTicket(
                id: "t1",
                walletID: "w1",
                eventID: "e1",
                tierCode: "vip",
                qrToken: "token1",
                status: .active,
                usedAt: nil,
                scannedBy: nil
            )
        )
        let viewModel = ScannerSessionViewModel(
            parser: MockParser(token: "token1"),
            repository: repository,
            authService: MockScannerAuthService(userID: "scanner-1")
        )

        await viewModel.handleScannedCode("ignored")

        #expect(viewModel.currentOutcome == .valid(ticketID: "t1"))
    }

    @Test func usedTicketReturnsAlreadyUsed() async {
        let repository = MockScannerTicketRepository(
            fetchedTicket: ScannerTicket(
                id: "t2",
                walletID: "w1",
                eventID: "e1",
                tierCode: "vip",
                qrToken: "token1",
                status: .used,
                usedAt: Date(),
                scannedBy: "scanner-0"
            )
        )
        let viewModel = ScannerSessionViewModel(
            parser: MockParser(token: "token1"),
            repository: repository,
            authService: MockScannerAuthService(userID: "scanner-1")
        )

        await viewModel.handleScannedCode("ignored")

        #expect(viewModel.currentOutcome == .alreadyUsed(ticketID: "t2"))
    }

    @Test func missingTicketReturnsInvalid() async {
        let viewModel = ScannerSessionViewModel(
            parser: MockParser(token: "token1"),
            repository: MockScannerTicketRepository(fetchedTicket: nil),
            authService: MockScannerAuthService(userID: "scanner-1")
        )

        await viewModel.handleScannedCode("ignored")

        #expect(viewModel.currentOutcome == .invalid(reason: "Ticket not found."))
    }

    @Test func repositoryErrorMapsToInvalid() async {
        let viewModel = ScannerSessionViewModel(
            parser: MockParser(token: "token1"),
            repository: MockScannerTicketRepository(fetchedTicket: nil, fetchError: ScannerTicketRepositoryError.permissionDenied),
            authService: MockScannerAuthService(userID: "scanner-1")
        )

        await viewModel.handleScannedCode("ignored")

        #expect(viewModel.currentOutcome == .invalid(reason: "Permission denied for scanner role."))
    }
}

private struct MockParser: QRPayloadParsing {
    let token: String

    func parse(_ payload: String) throws -> ParsedTicketPayload {
        ParsedTicketPayload(ticketID: "t", walletID: "w", eventID: "e", tierCode: "vip", qrToken: token)
    }
}

private struct MockScannerTicketRepository: ScannerTicketRepositoryProtocol {
    let fetchedTicket: ScannerTicket?
    var fetchError: Error?

    init(fetchedTicket: ScannerTicket?, fetchError: Error? = nil) {
        self.fetchedTicket = fetchedTicket
        self.fetchError = fetchError
    }

    func fetchTicketByQRToken(_ qrToken: String) async throws -> ScannerTicket? {
        if let fetchError { throw fetchError }
        return fetchedTicket
    }

    func redeemTicket(ticketID: String, scannerID: String) async throws {}
}

private struct MockScannerAuthService: ScannerAuthServicing {
    let userID: String

    var currentUserID: String? { userID }
    var isAuthenticated: Bool { true }

    func signIn(email: String, password: String) async throws {}
    func signOut() throws {}
}
