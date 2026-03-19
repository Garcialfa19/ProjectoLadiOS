import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var eventsViewModel = EventsViewModel()
    @StateObject private var ticketWalletViewModel = TicketWalletViewModel()
    @State private var selectedTheme: BrandTheme = .demoBar
    @AppStorage("prefersDarkMode") private var prefersDarkMode = false

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(theme: selectedTheme, prefersDarkMode: $prefersDarkMode)
                    .environmentObject(authViewModel)
                    .environmentObject(eventsViewModel)
                    .environmentObject(ticketWalletViewModel)
            } else {
                LoginView(theme: selectedTheme)
                    .environmentObject(authViewModel)
            }
        }
        .tint(selectedTheme.accent)
        .preferredColorScheme(prefersDarkMode ? .dark : nil)
    }
}

struct MainTabView: View {
    let theme: BrandTheme
    @Binding var prefersDarkMode: Bool

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(theme: theme)
            }
            .tabItem {
                Label("Events", systemImage: "ticket")
            }

            NavigationStack {
                WalletView(theme: theme)
            }
            .tabItem {
                Label("Wallet", systemImage: "wallet.pass")
            }

            NavigationStack {
                SettingsView(theme: theme, prefersDarkMode: $prefersDarkMode)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(theme.accent)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.thinMaterial, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
