import SwiftUI

struct SettingsView: View {
    let theme: BrandTheme
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("Profile, product status, and the Firestore-backed event model in one place.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    profileCard
                        .padding(.horizontal, 20)

                    productCard
                        .padding(.horizontal, 20)

                    Button("Sign Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.14), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(theme.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.user?.displayName ?? "Signed in user")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(authViewModel.user?.email ?? "No email available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            SettingsRow(icon: "checkmark.icloud", title: "Firebase Auth", subtitle: "Apple and Google sign-in are configured.")
            SettingsRow(icon: "shippingbox", title: "Event source", subtitle: "Events now load from Firestore with sample fallback.")
        }
        .padding(22)
        .glassCard(cornerRadius: 30)
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeaderView(
                title: "Data now stored per event",
                subtitle: "Good additions beyond title, date, and base price."
            )

            SettingsRow(icon: "building.2", title: "Venue context", subtitle: "Venue name, neighborhood, address, and map coordinates.")
            SettingsRow(icon: "clock.arrow.trianglehead.counterclockwise.rotate.90", title: "Operations detail", subtitle: "Doors open, end time, live status, capacity, and tickets remaining.")
            SettingsRow(icon: "sparkles.rectangle.stack", title: "Guest decision data", subtitle: "Lineup, genres, amenities, age policy, dress code, and parking.")
            SettingsRow(icon: "ticket", title: "Tier detail", subtitle: "Tier code, price, perks, inventory, and recommendation state.")
        }
        .padding(22)
        .glassCard(cornerRadius: 30)
    }
}
