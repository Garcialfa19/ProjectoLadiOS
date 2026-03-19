import Foundation

@MainActor
final class ScannerSessionViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var currentOutcome: ScanOutcome?

    private let parser: QRPayloadParsing
    private let repository: ScannerTicketRepositoryProtocol
    private let authService: ScannerAuthServicing

    init(
        parser: QRPayloadParsing = QRPayloadParser(),
        repository: ScannerTicketRepositoryProtocol = ScannerTicketRepository(),
        authService: ScannerAuthServicing
    ) {
        self.parser = parser
        self.repository = repository
        self.authService = authService
    }

    func handleScannedCode(_ payload: String) async {
        guard !isProcessing else { return }
        isProcessing = true

        let outcome: ScanOutcome
        do {
            let parsed = try parser.parse(payload)
            guard let ticket = try await repository.fetchTicketByQRToken(parsed.qrToken) else {
                outcome = .invalid(reason: "Ticket not found.")
                displayAndReset(outcome)
                return
            }

            if ticket.status != .active {
                outcome = .alreadyUsed(ticketID: ticket.id)
                displayAndReset(outcome)
                return
            }

            let scannerID = authService.currentUserID ?? "unknown-scanner"
            try await repository.redeemTicket(ticketID: ticket.id, scannerID: scannerID)
            outcome = .valid(ticketID: ticket.id)
        } catch let error as QRPayloadParserError {
            switch error {
            case .missingToken:
                outcome = .invalid(reason: "Malformed QR payload: missing token.")
            case .malformedPayload:
                outcome = .invalid(reason: "Malformed QR payload.")
            }
        } catch let error as SharedTicketRedemptionError {
            switch error {
            case .ticketAlreadyUsed:
                outcome = .alreadyUsed(ticketID: "")
            case .ticketNotFound:
                outcome = .invalid(reason: "Ticket not found.")
            }
        } catch let error as ScannerTicketRepositoryError {
            switch error {
            case .permissionDenied:
                outcome = .invalid(reason: "Permission denied for scanner role.")
            case .network:
                outcome = .invalid(reason: "Network unavailable.")
            case .unknown:
                outcome = .invalid(reason: "Unable to validate ticket.")
            }
        } catch {
            outcome = .invalid(reason: "Unable to validate ticket.")
        }

        displayAndReset(outcome)
    }

    private func displayAndReset(_ outcome: ScanOutcome) {
        currentOutcome = outcome
        ScannerHaptics.notify(success: outcome.isSuccess)

        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(1500))
            await MainActor.run {
                self?.currentOutcome = nil
                self?.isProcessing = false
            }
        }
    }
}
