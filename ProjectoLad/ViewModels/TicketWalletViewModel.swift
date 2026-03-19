import FirebaseFirestore
import Foundation

@MainActor
final class TicketWalletViewModel: ObservableObject {
    @Published private(set) var tickets: [TicketPass] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: TicketWalletRepositoryProtocol
    private var listener: ListenerRegistration?

    init(repository: TicketWalletRepositoryProtocol = FirestoreTicketWalletRepository()) {
        self.repository = repository
    }

    deinit {
        listener?.remove()
    }

    func startListening(userID: String) {
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = repository.listenForTickets(userID: userID) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let tickets):
                self.tickets = tickets
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func purchaseTicket(userID: String, userEmail: String?, event: Event, tier: TicketTier) async throws -> TicketPass {
        let ticket = try await repository.createTicket(for: userID, userEmail: userEmail, event: event, tier: tier)
        return ticket
    }
}
