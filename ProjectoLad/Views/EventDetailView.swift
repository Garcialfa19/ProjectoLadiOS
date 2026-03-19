import MapKit
import SwiftUI

struct EventDetailView: View {
    let theme: BrandTheme
    let event: Event

    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var ticketWalletViewModel: TicketWalletViewModel
    @State private var selectedTierID: TicketTier.ID?
    @State private var showPurchaseAlert = false
    @State private var purchaseAlertTitle = "Ticket added to Wallet"
    @State private var purchaseAlertMessage = ""
    @State private var isPurchasing = false

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private var selectedTier: TicketTier? {
        event.sortedTicketTiers.first { $0.id == selectedTierID }
    }

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            List {
                Section {
                    heroSection
                }

                Section {
                    essentialsSection
                }

                Section {
                    aboutSection
                }

                Section {
                    lineupSection
                }

                Section {
                    locationSection
                }

                Section {
                    accessSection
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            purchaseBar
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(.thinMaterial)
        }
        .alert(purchaseAlertTitle, isPresented: $showPurchaseAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(purchaseAlertMessage)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(event.badgeText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .liquidGlassCapsule()

                Spacer()

                Image(systemName: event.heroSymbol)
                    .font(.title2)
                    .foregroundStyle(theme.accent)
                    .padding(14)
                    .glassCard(cornerRadius: 18)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(event.subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Hosted by \(event.hostName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(event.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                EventInfoPill(icon: "calendar", title: event.startsDayText)
                EventInfoPill(icon: "clock", title: event.timeRangeText)
            }
        }
        .padding(.vertical, 8)
    }

    private var essentialsSection: some View {
        DetailSectionCard(title: "Essentials", subtitle: "The details most guests check before buying") {
            VStack(alignment: .leading, spacing: 16) {
                DetailValueRow(icon: "mappin", title: "Venue", value: event.locationSummary)
                DetailValueRow(icon: "door.left.hand.open", title: "Doors Open", value: event.doorsOpenText)
                DetailValueRow(icon: "ticket", title: "Availability", value: event.availabilityText)
                DetailValueRow(icon: "person.text.rectangle", title: "Age Policy", value: event.agePolicy)
                DetailValueRow(icon: "sparkles", title: "Dress Code", value: event.dressCode)
            }
        }
    }

    private var aboutSection: some View {
        DetailSectionCard(title: "About", subtitle: "Story, vibe, and on-site details") {
            VStack(alignment: .leading, spacing: 14) {
                Text(event.description)
                    .font(.body)
                    .foregroundStyle(.primary)

                if !event.musicGenres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(event.musicGenres, id: \.self) { genre in
                                Text(genre)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .liquidGlassCapsule()
                            }
                        }
                    }
                }

                if !event.amenities.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(event.amenities, id: \.self) { amenity in
                            Label(amenity, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                    }
                }

                DetailValueRow(icon: "parkingsign.circle", title: "Parking", value: event.parkingInfo)
            }
        }
    }

    private var lineupSection: some View {
        DetailSectionCard(title: "Lineup", subtitle: "Who is shaping the night") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(event.lineup, id: \.self) { artist in
                    HStack {
                        Text(artist)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 20)
                }
            }
        }
    }

    private var locationSection: some View {
        DetailSectionCard(title: "Location", subtitle: event.address) {
            VStack(alignment: .leading, spacing: 14) {
                Map(initialPosition: .region(mapRegion)) {
                    Marker(event.venueName, coordinate: event.coordinate)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text(event.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var accessSection: some View {
        DetailSectionCard(title: "Choose Access", subtitle: "Connected directly to Firestore ticket tier data") {
            VStack(spacing: 12) {
                ForEach(event.sortedTicketTiers) { tier in
                    TicketTierRow(
                        tier: tier,
                        theme: theme,
                        isSelected: selectedTierID == tier.id
                    ) {
                        selectedTierID = tier.id
                    }
                }
            }
        }
    }

    private var purchaseBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedTier?.name ?? "Select a ticket")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(selectedTier?.priceText ?? event.priceFromText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task {
                    await purchaseSelectedTicket()
                }
            } label: {
                Text(buttonTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(theme.accent, in: Capsule())
            }
            .disabled(selectedTier == nil || isPurchasing)
            .opacity((selectedTier == nil || isPurchasing) ? 0.55 : 1)
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
    }

    private var buttonTitle: String {
        if isPurchasing { return "Creating Ticket..." }
        return selectedTier == nil ? "Choose Access" : "Continue"
    }

    private func purchaseSelectedTicket() async {
        guard let user = authViewModel.user else {
            purchaseAlertTitle = "Sign in required"
            purchaseAlertMessage = "You need to be signed in before a ticket can be created."
            showPurchaseAlert = true
            return
        }

        guard let selectedTier else {
            purchaseAlertTitle = "Choose a ticket"
            purchaseAlertMessage = "Select a ticket tier first."
            showPurchaseAlert = true
            return
        }

        isPurchasing = true

        do {
            let ticket = try await ticketWalletViewModel.purchaseTicket(
                userID: user.uid,
                userEmail: user.email,
                event: event,
                tier: selectedTier
            )

            purchaseAlertTitle = "Ticket added to Wallet"
            purchaseAlertMessage = "A unique QR ticket for \(ticket.tierName) was created and stored in Firebase. It will appear in Wallet and can later be invalidated by your scanning system."
            showPurchaseAlert = true
        } catch {
            purchaseAlertTitle = "Ticket creation failed"
            purchaseAlertMessage = error.localizedDescription
            showPurchaseAlert = true
        }

        isPurchasing = false
    }
}
