import SwiftUI

struct ScannerResultView: View {
    let outcome: ScanOutcome

    var body: some View {
        VStack(spacing: 8) {
            Text(outcome.title)
                .font(.title2.bold())
            Text(outcome.detail)
                .multilineTextAlignment(.center)
                .font(.subheadline)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(outcome.isSuccess ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 20)
        .shadow(radius: 12)
    }
}
