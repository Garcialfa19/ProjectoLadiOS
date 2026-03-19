import FirebaseAuth
import Foundation

protocol ScannerAuthServicing {
    var currentUserID: String? { get }
    var isAuthenticated: Bool { get }
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

enum ScannerAuthError: LocalizedError, Equatable {
    case invalidCredentials
    case unauthorizedRole
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .unauthorizedRole:
            return "Account is not authorized for scanning."
        case .network:
            return "Network issue. Try again."
        case .unknown:
            return "Unable to authenticate."
        }
    }
}

struct ScannerAuthService: ScannerAuthServicing {
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let token = try await result.user.getIDTokenResult()
            let role = token.claims["role"] as? String
            guard role == "scanner" else {
                try? Auth.auth().signOut()
                throw ScannerAuthError.unauthorizedRole
            }
        } catch {
            throw mapError(error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func mapError(_ error: Error) -> ScannerAuthError {
        if let authError = error as? ScannerAuthError {
            return authError
        }

        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: nsError.code)
        else {
            return .unknown
        }

        switch code {
        case .wrongPassword, .userNotFound, .invalidCredential, .invalidEmail:
            return .invalidCredentials
        case .networkError, .tooManyRequests:
            return .network
        default:
            return .unknown
        }
    }
}
