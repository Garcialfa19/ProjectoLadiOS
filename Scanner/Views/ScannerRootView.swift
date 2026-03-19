import SwiftUI

struct ScannerRootView: View {
    @StateObject private var sessionViewModel: ScannerSessionViewModel
    @StateObject private var loginViewModel: ScannerLoginViewModel
    @State private var isAuthenticated: Bool

    private let authService: ScannerAuthServicing

    init(
        authService: ScannerAuthServicing = ScannerAuthService(),
        ticketRepository: ScannerTicketRepositoryProtocol = ScannerTicketRepository(),
        parser: QRPayloadParsing = QRPayloadParser()
    ) {
        self.authService = authService
        _isAuthenticated = State(initialValue: authService.isAuthenticated)
        _loginViewModel = StateObject(wrappedValue: ScannerLoginViewModel(authService: authService))
        _sessionViewModel = StateObject(wrappedValue: ScannerSessionViewModel(parser: parser, repository: ticketRepository, authService: authService))
    }

    var body: some View {
        Group {
            if isAuthenticated {
                scannerContent
            } else {
                ScannerLoginView(viewModel: loginViewModel) {
                    isAuthenticated = true
                }
            }
        }
    }

    private var scannerContent: some View {
        ZStack(alignment: .bottom) {
            ScannerCameraView(isPaused: .constant(sessionViewModel.isProcessing || sessionViewModel.currentOutcome != nil)) { payload in
                Task {
                    await sessionViewModel.handleScannedCode(payload)
                }
            }

            if let outcome = sessionViewModel.currentOutcome {
                ScannerResultView(outcome: outcome)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
