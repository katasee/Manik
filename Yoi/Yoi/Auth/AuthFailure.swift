import SwiftUI

enum AuthFailure {
    case wrongCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case tooManyRequests
    case network
    case generic

    init(_ error: AccountError) {
        switch error {
        case .wrongPassword:
            self = .wrongCredentials
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .weakPassword:
            self = .weakPassword
        case .invalidEmail:
            self = .invalidEmail
        case .tooManyRequests:
            self = .tooManyRequests
        case .network:
            self = .network
        case .profileNotFound, .requiresRecentLogin, .generic:
            self = .generic
        }
    }

    var messageKey: LocalizedStringKey {
        switch self {
        case .wrongCredentials: "auth.error.wrongCredentials"
        case .emailAlreadyInUse: "auth.error.emailAlreadyInUse"
        case .weakPassword: "account.error.weakPassword"
        case .invalidEmail: "auth.error.invalidEmail"
        case .tooManyRequests: "auth.error.tooManyRequests"
        case .network: "auth.error.network"
        case .generic: "auth.error.generic"
        }
    }
}
