import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CryptoKit
import UIKit

@MainActor
final class AuthViewModel: NSObject, ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    override init() {
        super.init()
        user = Auth.auth().currentUser

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    var isLoggedIn: Bool {
        user != nil
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Firebase client ID."
            return
        }

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            errorMessage = "Could not find root view controller."
            return
        }

        isLoading = true
        errorMessage = nil

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Missing Google ID token."
                isLoading = false
                return
            }

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            _ = try await Auth.auth().signIn(with: credential)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func startSignInWithAppleFlow() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    func handleAppleAuthorization(_ authorization: ASAuthorization) async {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid Apple credential."
            return
        }

        guard let nonce = currentNonce else {
            errorMessage = "Invalid Apple sign-in state."
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            errorMessage = "Missing Apple identity token."
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Could not serialize Apple token."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            _ = try await Auth.auth().signIn(with: credential)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func handleAppleError(_ error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorMessage = "Apple sign-in was canceled."
            case .notHandled:
                errorMessage = "Apple sign-in could not be completed. Please try again."
            case .failed:
                errorMessage = "Apple sign-in failed. On Simulator, enable passcode and sign in to iCloud, or test on a physical device."
            case .invalidResponse:
                errorMessage = "Apple sign-in returned an invalid response."
            case .unknown:
                errorMessage = "Apple sign-in is unavailable on this device configuration."
            case .notInteractive:
                errorMessage = "Apple sign-in needs an interactive session. Please retry."
            default:
                errorMessage = "Apple sign-in failed: \(error.localizedDescription)"
            }
            return
        }

        errorMessage = "Apple sign-in failed: \(error.localizedDescription)"
    }
}

private extension AuthViewModel {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if Int(random) < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
