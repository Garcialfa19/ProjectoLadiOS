import SwiftUI

struct SettingsView: View {
    let theme: BrandTheme
    @Binding var prefersDarkMode: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var ticketWalletViewModel: TicketWalletViewModel
    @State private var showPaymentAlert = false

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.user?.displayName ?? "Signed in user")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(authViewModel.user?.email ?? "No email available")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section {
                    Toggle("Dark Mode", isOn: $prefersDarkMode)

                    Button {
                        showPaymentAlert = true
                    } label: {
                        HStack {
                            Text("Add Payment Method")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button("Sign Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                }

                WalletSectionView(
                    tickets: ticketWalletViewModel.tickets,
                    isLoading: ticketWalletViewModel.isLoading,
                    errorMessage: ticketWalletViewModel.errorMessage
                )
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let userID = authViewModel.user?.uid {
                ticketWalletViewModel.startListening(userID: userID)
            }
        }
        .alert("Payment Methods", isPresented: $showPaymentAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Payment method management still needs to be connected.")
        }
    }
}
