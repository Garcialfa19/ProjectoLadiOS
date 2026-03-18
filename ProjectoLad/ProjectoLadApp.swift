import SwiftUI
import FirebaseCore

@main
struct ProjectoLadApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
