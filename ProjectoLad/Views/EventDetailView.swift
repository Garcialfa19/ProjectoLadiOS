import SwiftUI
import MapKit

struct EventDetailView: View {
    let theme: BrandTheme
    let event: Event
    @State private var selectedTierID: TicketTier.ID?
    @State private var showPurchaseAlert = false

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private var selectedTier: TicketTier? {
        event.ticketTiers.first { $0.id == selectedTierID }
    }

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [theme.accent.opacity(0.95), theme.secondaryAccent.opacity(0.75), Color.black.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 330)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.badgeText.uppercased())
                                .font(.caption2.weight(.bold))
                                .tracking(1.2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .liquidGlassCapsule()

                            Text(event.title)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(event.subtitle)
                                .font(.headline)
                                .foregroundStyle(Color.white.opacity(0.78))

                            Text(event.hostName)
                                .font(.footnote)
                                .foregroundStyle(Color.white.opacity(0.62))
                        }
                        .padding(24)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 130, height: 130)
                            .blur(radius: 34)
                            .offset(x: 26, y: -18)
                    }
                    .padding(.top, 6)

                    HStack(spacing: 16) {
                        DetailPill(icon: "calendar", title: event.dateText)
                        DetailPill(icon: "clock", title: event.timeText)
                        DetailPill(icon: "ticket.fill", title: "From \(event.basePriceText)")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("About this event")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text(event.description)
                            .foregroundStyle(Color.white.opacity(0.72))
                            .font(.body)
                    }
                    .padding(20)
                    .glassCard()

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Location")
                            .font(.title3.bold())
                            .foregroundStyle(.white)

                        Map(initialPosition: .region(mapRegion)) {
                            Marker(event.title, coordinate: event.coordinate)
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                        Label(event.address, systemImage: "mappin.and.ellipse")
                            .foregroundStyle(Color.white.opacity(0.70))
                            .font(.subheadline)
                    }
                    .padding(20)
                    .glassCard()

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Choose your access")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(event.ticketTiers.count) tiers")
                                .font(.footnote)
                                .foregroundStyle(Color.white.opacity(0.60))
                        }

                        ForEach(event.ticketTiers) { tier in
                            TicketTierRow(
                                tier: tier,
                                theme: theme,
                                isSelected: selectedTierID == tier.id
                            ) {
                                selectedTierID = tier.id
                            }
                        }
                    }
                    .padding(20)
                    .glassCard()

                    Button {
                        showPurchaseAlert = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedTierID == nil ? "Select a ticket first" : "Continue to purchase")
                                    .font(.headline)
                                Text(selectedTier?.priceText ?? "Choose a tier to unlock checkout")
                                    .font(.footnote)
                                    .foregroundStyle(Color.white.opacity(0.72))
                            }

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.headline.bold())
                        }
                        .foregroundStyle(.white)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: selectedTierID == nil
                                                    ? [Color.white.opacity(0.08), Color.white.opacity(0.03)]
                                                    : [theme.accent.opacity(0.88), theme.secondaryAccent.opacity(0.66)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .disabled(selectedTierID == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Flow Coming Soon", isPresented: $showPurchaseAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let selectedTier {
                Text("You selected the \(selectedTier.name) ticket for \(selectedTier.priceText). The real checkout flow still needs to be connected.")
            } else {
                Text("Please select a ticket first.")
            }
        }
    }
}
