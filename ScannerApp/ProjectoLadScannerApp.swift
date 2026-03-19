import FirebaseCore
import SwiftUI

@main
struct ProjectoLadScannerApp: App {
    private let isFirebaseConfigured: Bool

    init() {
        self.isFirebaseConfigured = Self.configureFirebaseIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            if isFirebaseConfigured {
                ScannerRootView()
            } else {
                ScannerFirebaseSetupView()
            }
        }
    }
}

private extension ProjectoLadScannerApp {
    static func configureFirebaseIfPossible() -> Bool {
        if FirebaseApp.app() != nil {
            return true
        }

        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else {
            return false
        }

        FirebaseApp.configure(options: options)
        return true
    }
}
