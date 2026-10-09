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

    /// `reportsPending` is false for the automatic check on returning to the app, which
    /// should not flash "not verified yet" at a master who hasn't opened the email.
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

        // The reload above already flipped the cached flag, so RootViewModel.refresh() will treat
        // her as verified and skip its own refresh — the rules need the new `email_verified` claim now.
        try? await authRepository.refreshIdToken()

        return true
    }

    /// Starts the cooldown only after a send or Firebase's rate limit — a network failure can be
    /// retried at once.
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

    /// Driven by the view's `.task(id: cooldownRun)`, so it stops when the screen goes away.
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
