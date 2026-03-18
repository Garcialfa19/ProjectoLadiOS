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
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Manage your profile, branding hooks, and future nightlife features.")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.70))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Brand")
                            .font(.headline)
                            .foregroundStyle(.white)

                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.accent, theme.secondaryAccent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 54, height: 54)

                                Image(systemName: theme.logoSystemName)
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(theme.barName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("White-label theme ready")
                                    .font(.footnote)
                                    .foregroundStyle(Color.white.opacity(0.65))
                            }

                            Spacer()
                        }
                    }
                    .padding(20)
                    .glassCard()
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Account")
                            .font(.headline)
                            .foregroundStyle(.white)

                        if let user = authViewModel.user {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.displayName ?? "Signed in user")
                                    .foregroundStyle(.white)
                                Text(user.email ?? "No email available")
                                    .font(.footnote)
                                    .foregroundStyle(Color.white.opacity(0.65))
                            }
                        }

                        Button("Sign Out", role: .destructive) {
                            authViewModel.signOut()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.85))
                    }
                    .padding(20)
                    .glassCard()
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Coming later")
                            .font(.headline)
                            .foregroundStyle(.white)

                        SettingsRow(icon: "ticket.fill", title: "Saved tickets", subtitle: "Quick access to active QR passes")
                        SettingsRow(icon: "creditcard.fill", title: "Payment methods", subtitle: "Store preferred checkout options")
                        SettingsRow(icon: "questionmark.circle.fill", title: "Support", subtitle: "Help center and event contact tools")
                    }
                    .padding(20)
                    .glassCard()
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}
