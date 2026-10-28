import SwiftUI
import Observation

enum ResetPasswordFailure {
    case invalidEmail
    case network
    case generic

    var messageKey: LocalizedStringKey {
        switch self {
        case .invalidEmail: "auth.error.invalidEmail"
        case .network: "auth.error.network"
        case .generic: "auth.error.generic"
        }
    }
}

@MainActor
@Observable
final class ResetPasswordViewModel {
    var email: String

    private(set) var isSending = false
    private(set) var isSent = false
    private(set) var failure: ResetPasswordFailure?

    private let authRepository: AuthRepository

    init(email: String, authRepository: AuthRepository = FirebaseAuthRepository()) {
        self.email = email
        self.authRepository = authRepository
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSubmit: Bool {
        trimmedEmail.isEmpty == false
    }

    func send() async {
        guard isSending == false, canSubmit else { return }

        isSending = true
        failure = nil
        defer { isSending = false }

        do {
            try await authRepository.sendPasswordReset(email: trimmedEmail)
            isSent = true
        } catch AccountError.invalidEmail {
            failure = .invalidEmail
        } catch AccountError.network {
            failure = .network
        } catch {
            failure = .generic
        }
    }
}
