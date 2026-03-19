import AuthenticationServices
import SwiftUI

struct LoginView: View {
    let theme: BrandTheme
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            AppBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 28)

                    VStack(spacing: 18) {
                        Image(systemName: theme.logoSystemName)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(theme.accent, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                        VStack(spacing: 8) {
                            Text("Event passes, designed for iPhone")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)

                            Text("Sign in to browse live events, inspect venue details, and keep every ticket tier in one native flow.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Continue")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)

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
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
#if targetEnvironment(simulator)
                        .disabled(true)
                        .overlay(alignment: .topLeading) {
                            Text("Apple Sign In on Simulator may fail unless iCloud + passcode are configured.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .offset(y: -20)
                        }
#endif

                        AuthButton(
                            title: authViewModel.isLoading ? "Signing in..." : "Continue with Google",
                            systemImage: "globe",
                            background: Color(uiColor: .secondarySystemBackground),
                            foreground: .primary
                        ) {
                            Task {
                                await authViewModel.signInWithGoogle()
                            }
                        }
                    }
                    .padding(22)
                    .glassCard(cornerRadius: 30)
                    .padding(.horizontal, 20)

                    .padding(22)
                    .glassCard(cornerRadius: 30)
                    .padding(.horizontal, 20)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
    }
}
