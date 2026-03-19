import FirebaseCore
import SwiftUI

@main
struct ProjectoLadScannerApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ScannerRootView()
        }
    }
}
