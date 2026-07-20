import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    enum Mode {
        case signIn
        case signUp
    }

    var mode: Mode = .signIn
    var email = "" {
        didSet { errorMessage = nil }
    }
    var password = "" {
        didSet { errorMessage = nil }
    }
    var name = "" {
        didSet { errorMessage = nil }
    }
    var errorMessage: String?
    var isLoading = false

    private let repository: AuthRepository

    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
    }

    private var hasCredentials: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var canSubmit: Bool {
        switch mode {
        case .signIn: hasCredentials
        case .signUp: hasCredentials && !name.isEmpty
        }
    }

    func submit() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            switch mode {
            case .signIn:
                try await repository.signIn(email: email, password: password)
            case .signUp:
                try await repository.signUp(
                    email: email,
                    password: password,
                    name: name
                )
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
