import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct WalletView: View {
    let theme: BrandTheme
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var ticketWalletViewModel: TicketWalletViewModel

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            List {
                WalletSectionView(
                    tickets: ticketWalletViewModel.tickets,
                    isLoading: ticketWalletViewModel.isLoading,
                    errorMessage: ticketWalletViewModel.errorMessage
                )
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.large)
        .task(id: authViewModel.user?.uid) {
            guard let userID = authViewModel.user?.uid else {
                ticketWalletViewModel.stopListening()
                return
            }

            ticketWalletViewModel.startListening(userID: userID)
        }
    }
}

struct WalletSectionView: View {
    let tickets: [TicketPass]
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        Section("Wallet") {
            if isLoading && tickets.isEmpty {
                ProgressView("Loading tickets...")
            } else if tickets.isEmpty {
                Text("Tickets you purchase will appear here with a unique QR code.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(tickets) { ticket in
                    WalletTicketCard(ticket: ticket)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WalletTicketCard: View {
    let ticket: TicketPass
    @State private var showLargeQR = false
    @State private var showWalletInfoAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.eventTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(ticket.venueName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(ticket.statusTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ticket.status == .active ? .green : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .liquidGlassCapsule()
            }

            HStack(alignment: .top, spacing: 16) {
                QRCodeView(payload: ticket.qrPayload)
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onTapGesture {
                        showLargeQR = true
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Label(ticket.tierName, systemImage: "ticket")
                    Label(ticket.eventDateText, systemImage: "calendar")
                    Label(ticket.priceText, systemImage: "creditcard")
                    Label("Code \(ticket.shortCode)", systemImage: "number")
                    if let usedAt = ticket.usedAt {
                        Label("Scanned \(usedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))", systemImage: "checkmark.seal")
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    showLargeQR = true
                } label: {
                    Label("Enlarge QR", systemImage: "qrcode.viewfinder")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)

                if let appleWalletPassURL = ticket.appleWalletPassURL {
                    Link(destination: appleWalletPassURL) {
                        Label("Add to Apple Wallet", systemImage: "wallet.pass")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        showWalletInfoAlert = true
                    } label: {
                        Label("Add to Apple Wallet", systemImage: "wallet.pass")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showLargeQR) {
            LargeQRCodeSheet(ticket: ticket)
        }
        .alert("Apple Wallet Pass Not Ready", isPresented: $showWalletInfoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This ticket does not have a signed .pkpass URL yet. Once your pass generation service is connected, this button will open Apple Wallet.")
        }
    }
}

private struct LargeQRCodeSheet: View {
    let ticket: TicketPass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                QRCodeView(payload: ticket.qrPayload)
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Text(ticket.eventTitle)
                    .font(.headline)
                Text("Code \(ticket.shortCode)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ShareLink(item: ticket.qrPayload) {
                    Label("Share QR Payload", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Ticket QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QRCodeView: View {
    let payload: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        if let image = makeImage() {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(10)
                .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    Image(systemName: "qrcode")
                        .foregroundStyle(.secondary)
                }
        }
    }

    private func makeImage() -> UIImage? {
        filter.message = Data(payload.utf8)

        guard let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)),
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
