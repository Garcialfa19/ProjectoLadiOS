import SwiftUI

struct ScannerFirebaseSetupView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundStyle(.yellow)

            Text("Firebase Not Configured")
                .font(.title3.bold())

            Text("Add GoogleService-Info.plist to the ProjectoLadScanner target membership, then relaunch the app.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}
