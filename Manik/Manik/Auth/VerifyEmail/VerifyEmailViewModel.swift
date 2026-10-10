import SwiftUI
import Observation

enum VerifyEmailMessage {
    case notVerified
    case sent
    case tooManyRequests
    case generic

    var messageKey: LocalizedStringKey {
        switch self {
        case .notVerified: "auth.verify.notVerified"
        case .sent: "auth.verify.sent"
        case .tooManyRequests: "auth.error.tooManyRequests"
        case .generic: "auth.error.generic"
        }
    }

    var isError: Bool {
        self != .sent
    }
}

@MainActor
@Observable
final class VerifyEmailViewModel {
    static let resendCooldown = 60

    let email: String

    private(set) var isChecking = false
    private(set) var isResending = false
    private(set) var resendSecondsLeft = 0
    private(set) var cooldownRun = 0
    private(set) var message: VerifyEmailMessage?

    private let authRepository: AuthRepository

    init(email: String, authRepository: AuthRepository = FirebaseAuthRepository()) {
        self.email = email
        self.authRepository = authRepository
    }

    var canResend: Bool {
        isResending == false && resendSecondsLeft == 0
    }

    func check(reportsPending: Bool) async -> Bool {
        guard isChecking == false else { return false }

        isChecking = true
        defer { isChecking = false }

        do {
            try await authRepository.reloadUser()
        } catch {
            if reportsPending { message = .generic }

            return false
        }

        guard authRepository.isEmailVerified else {
            if reportsPending { message = .notVerified }

            return false
        }

        try? await authRepository.refreshIdToken()

        return true
    }

    func resend() async {
        guard canResend else { return }

        isResending = true
        message = nil
        defer { isResending = false }

        do {
            try await authRepository.sendEmailVerification()
            message = .sent
        } catch AccountError.tooManyRequests {
            message = .tooManyRequests
        } catch {
            message = .generic
            return
        }

        resendSecondsLeft = Self.resendCooldown
        cooldownRun += 1
    }

    func runCooldown() async {
        while resendSecondsLeft > 0 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            resendSecondsLeft -= 1
        }
    }
}
