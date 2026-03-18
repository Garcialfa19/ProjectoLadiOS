import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTheme: BrandTheme = .demoBar

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(theme: selectedTheme)
                    .environmentObject(authViewModel)
            } else {
                LoginView(theme: selectedTheme)
                    .environmentObject(authViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    let theme: BrandTheme

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(theme: theme, events: Event.sampleEvents)
            }
            .tabItem {
                Label("Events", systemImage: "sparkles")
            }

            NavigationStack {
                SettingsView(theme: theme)
            }
            .tabItem {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
        }
        .tint(theme.accent)
    }
}

#Preview {
    ContentView()
}
