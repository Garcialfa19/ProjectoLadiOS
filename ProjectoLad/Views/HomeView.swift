import FirebaseFirestore
import SwiftUI

struct HomeView: View {
    let theme: BrandTheme
    @EnvironmentObject private var eventsViewModel: EventsViewModel
    @State private var searchText = ""

    private var filteredEvents: [Event] {
        eventsViewModel.events.filter { event in
            let matchesSearch = searchText.isEmpty
                || event.title.localizedCaseInsensitiveContains(searchText)
                || event.venueName.localizedCaseInsensitiveContains(searchText)
                || event.musicGenres.joined(separator: " ").localizedCaseInsensitiveContains(searchText)

            return matchesSearch
        }
    }

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            List {
                Section(eventsViewModel.isLoading ? "Loading Events" : "Upcoming Events") {
                    ForEach(filteredEvents) { event in
                        NavigationLink(value: event) {
                            EventRowCard(event: event, theme: theme)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let errorMessage = eventsViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search events, venues, or genres")
        .navigationDestination(for: Event.self) { event in
            EventDetailView(theme: theme, event: event)
        }
        .task {
            eventsViewModel.startListening()
        }
    }
}

#if DEBUG
private struct HomeViewPreviewRepository: EventsRepositoryProtocol {
    let events: [Event]

    func listenForEvents(onChange: @escaping (Result<[Event], any Error>) -> Void) -> ListenerRegistration {
        onChange(.success(events))
        return HomeViewPreviewListener()
    }
}

private final class HomeViewPreviewListener: ListenerRegistration {
    func remove() {}
}

#Preview {
    NavigationStack {
        HomeView(theme: .demoBar)
            .environmentObject(EventsViewModel(repository: HomeViewPreviewRepository(events: Event.sampleEvents)))
    }
}
#endif
