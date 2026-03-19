import FirebaseCore
import SwiftUI

struct SettingsView: View {
    let theme: BrandTheme
    @Binding var prefersDarkMode: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
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
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Payment Methods", isPresented: $showPaymentAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Payment method management still needs to be connected.")
        }
    }
}

#if DEBUG
private struct SettingsPreviewHost: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var prefersDarkMode = false

    var body: some View {
        NavigationStack {
            SettingsView(theme: .demoBar, prefersDarkMode: $prefersDarkMode)
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    Group {
        if FirebaseApp.app() != nil {
            SettingsPreviewHost()
        } else {
            ContentUnavailableView("Preview requires Firebase setup", systemImage: "gear.badge.xmark", description: Text("Open the app target once to configure Firebase, then refresh this canvas."))
        }
    }
}
#endif
