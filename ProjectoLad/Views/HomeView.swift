import SwiftUI

struct HomeView: View {
    let theme: BrandTheme
    @EnvironmentObject private var eventsViewModel: EventsViewModel
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .all

    private var filteredEvents: [Event] {
        eventsViewModel.events.filter { event in
            let matchesSearch = searchText.isEmpty
                || event.title.localizedCaseInsensitiveContains(searchText)
                || event.venueName.localizedCaseInsensitiveContains(searchText)
                || event.musicGenres.joined(separator: " ").localizedCaseInsensitiveContains(searchText)

            guard matchesSearch else { return false }

            switch selectedFilter {
            case .all:
                return true
            case .featured:
                return event.isFeatured
            case .thisWeek:
                guard let weekAhead = Calendar.current.date(byAdding: .day, value: 7, to: .now) else { return true }
                return event.startDate <= weekAhead
            case .sellingFast:
                return (event.ticketsRemaining ?? 99) < 25
            }
        }
    }

    private var featuredEvent: Event? {
        filteredEvents.first(where: { $0.isFeatured }) ?? filteredEvents.first
    }

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Discover")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)

                        Text("A native event view with clearer timing, venue details, and purchase context.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        searchField

                        HStack(spacing: 12) {
                            SummaryMetricView(title: "Upcoming", value: "\(eventsViewModel.events.count)")
                            SummaryMetricView(title: "Featured", value: "\(eventsViewModel.featuredEvents.count)")
                            SummaryMetricView(title: "Starting", value: eventsViewModel.events.first?.priceFromText ?? "--")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(EventFilter.allCases) { filter in
                                FilterChip(title: filter.title, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if let featuredEvent {
                        SectionHeaderView(title: "Featured", subtitle: "Highlighted by the venue team")
                            .padding(.horizontal, 20)

                        NavigationLink(value: featuredEvent) {
                            FeaturedEventCard(event: featuredEvent, theme: theme)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeaderView(
                        title: "Upcoming Events",
                        subtitle: eventsViewModel.isLoading ? "Loading Firestore events..." : "Live event cards designed to feel at home on iOS."
                    )
                    .padding(.horizontal, 20)

                    VStack(spacing: 14) {
                        ForEach(filteredEvents) { event in
                            NavigationLink(value: event) {
                                EventRowCard(event: event, theme: theme)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    if let errorMessage = eventsViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Event.self) { event in
            EventDetailView(theme: theme, event: event)
        }
        .task {
            eventsViewModel.startListening()
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search events, venues, or genres", text: $searchText)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 22)
    }
}

private enum EventFilter: String, CaseIterable, Identifiable {
    case all
    case featured
    case thisWeek
    case sellingFast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .featured:
            return "Featured"
        case .thisWeek:
            return "This Week"
        case .sellingFast:
            return "Selling Fast"
        }
    }
}
