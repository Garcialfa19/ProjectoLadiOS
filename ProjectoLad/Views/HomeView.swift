import SwiftUI

struct HomeView: View {
    let theme: BrandTheme
    let events: [Event]

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Tonight’s scene")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Discover curated events, premium access, and beautifully presented ticket experiences.")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.72))

                        HStack(spacing: 12) {
                            CapsuleInfo(title: "3", subtitle: "Live Events")
                            CapsuleInfo(title: "VIP", subtitle: "Tables")
                            CapsuleInfo(title: "QR", subtitle: "Entry")
                        }
                    }
                    .padding(24)
                    .glassCard(cornerRadius: 30)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    SectionHeaderView(title: "Featured events", subtitle: "Built for nightlife brands that want a premium feel.")
                        .padding(.horizontal, 20)

                    ForEach(events) { event in
                        NavigationLink(value: event) {
                            EventCardView(theme: theme, event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationDestination(for: Event.self) { event in
            EventDetailView(theme: theme, event: event)
        }
    }
}
