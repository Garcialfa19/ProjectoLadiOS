import SwiftUI

struct ScannerOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)

            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: 260, height: 260)

            VStack {
                Spacer()
                Text("Align QR inside the frame")
                    .foregroundStyle(.white)
                    .padding(.bottom, 80)
            }
        }
        .ignoresSafeArea()
    }
}
