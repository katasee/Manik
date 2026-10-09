import SwiftUI

enum PasswordFailure {
    case mismatch
    case weak
    case wrongPassword
    case requiresRecentLogin
    case generic

    init(_ error: AccountError) {
        switch error {
        case .wrongPassword:
            self = .wrongPassword
        case .weakPassword:
            self = .weak
        case .requiresRecentLogin:
            self = .requiresRecentLogin
        case .profileNotFound, .invalidEmail, .tooManyRequests, .network, .generic:
            self = .generic
        }
    }

    var messageKey: LocalizedStringKey {
        switch self {
        case .mismatch: "account.error.passwordMismatch"
        case .weak: "account.error.weakPassword"
        case .wrongPassword: "account.error.wrongPassword"
        case .requiresRecentLogin: "account.error.requiresRecentLogin"
        case .generic: "account.error.generic"
        }
    }
}
