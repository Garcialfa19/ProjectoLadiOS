import SwiftUI
import AuthenticationServices

struct LoginView: View {
    let theme: BrandTheme
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)

                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 82, height: 82)
                                .overlay {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [theme.accent.opacity(0.55), theme.secondaryAccent.opacity(0.30)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .overlay {
                                    Circle()
                                        .stroke(Color.white.opacity(0.26), lineWidth: 1)
                                }
                                .shadow(color: theme.accent.opacity(0.35), radius: 20, x: 0, y: 14)

                            Image(systemName: theme.logoSystemName)
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        VStack(spacing: 10) {
                            Text(theme.barName)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Discover curated events, buy premium tickets, and keep every pass in one sleek experience.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.white.opacity(0.72))
                                .padding(.horizontal, 18)
                        }
                    }
                    .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Get started")
                            .font(.headline)
                            .foregroundStyle(.white)

                        SignInWithAppleButton(
                            onRequest: { request in
                                let configuredRequest = authViewModel.startSignInWithAppleFlow()
                                request.requestedScopes = configuredRequest.requestedScopes
                                request.nonce = configuredRequest.nonce
                            },
                            onCompletion: { result in
                                Task {
                                    switch result {
                                    case .success(let authorization):
                                        await authViewModel.handleAppleAuthorization(authorization)
                                    case .failure(let error):
                                        authViewModel.handleAppleError(error)
                                    }
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        AuthButton(
                            title: authViewModel.isLoading ? "Signing in..." : "Continue with Google",
                            systemImage: "globe",
                            background: Color.white.opacity(0.08),
                            foreground: .white
                        ) {
                            Task {
                                await authViewModel.signInWithGoogle()
                            }
                        }
                    }
                    .padding(24)
                    .glassCard()
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("Why users love it")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "ticket.fill")
                                .foregroundStyle(theme.secondaryAccent)
                        }

                        FeatureRow(icon: "sparkles", title: "Curated events", subtitle: "Highlight premium nightlife experiences with rich event cards and host branding.")
                        FeatureRow(icon: "creditcard.fill", title: "Fast checkout", subtitle: "Ready for Apple Pay or Stripe once your payment flow is connected.")
                        FeatureRow(icon: "qrcode", title: "Digital tickets", subtitle: "Keep ticket delivery, QR entry, and wallet-ready passes in one place.")
                    }
                    .padding(24)
                    .glassCard()
                    .padding(.horizontal, 24)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(Color.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }
}
