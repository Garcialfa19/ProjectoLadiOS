import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var eventsViewModel = EventsViewModel()
    @State private var selectedTheme: BrandTheme = .demoBar

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(theme: selectedTheme)
                    .environmentObject(authViewModel)
                    .environmentObject(eventsViewModel)
            } else {
                LoginView(theme: selectedTheme)
                    .environmentObject(authViewModel)
            }
        }
        .tint(selectedTheme.accent)
    }
}

struct MainTabView: View {
    let theme: BrandTheme

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(theme: theme)
            }
            .tabItem {
                Label("Discover", systemImage: "sparkles")
            }

            NavigationStack {
                SettingsView(theme: theme)
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
        .tint(theme.accent)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.regularMaterial, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
