import FirebaseFirestore
import Foundation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published private(set) var events: [Event] = Event.sampleEvents
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?

    private let repository: EventsRepositoryProtocol
    private var listener: ListenerRegistration?

    init(repository: EventsRepositoryProtocol = FirestoreEventsRepository()) {
        self.repository = repository
    }

    deinit {
        listener?.remove()
    }

    var featuredEvents: [Event] {
        events.filter { $0.isFeatured }
    }

    func startListening() {
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = repository.listenForEvents { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let events):
                let validEvents = events
                    .filter { $0.status != .cancelled }
                    .sorted { $0.startDate < $1.startDate }

                self.events = validEvents.isEmpty ? Event.sampleEvents : validEvents
                self.isLoading = false
                self.errorMessage = validEvents.isEmpty
                    ? "Showing sample events until Firestore has live event documents."
                    : nil

            case .failure(let error):
                self.events = Event.sampleEvents
                self.isLoading = false
                self.errorMessage = "Showing sample events because Firestore could not be loaded: \(error.localizedDescription)"
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
