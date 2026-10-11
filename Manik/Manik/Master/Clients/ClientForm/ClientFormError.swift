import SwiftUI

struct ClientFormErrors {
    var instagram: ClientFormError?
    var phone: ClientFormError?
    var save: ClientFormError?
}

enum ClientFormError {
    case missingNameOrHandle
    case duplicateHandle
    case incompletePhone
    case saveFailed

    var messageKey: LocalizedStringKey {
        switch self {
        case .missingNameOrHandle: "clients.form.error.missingNameOrHandle"
        case .duplicateHandle: "clients.form.error.duplicateHandle"
        case .incompletePhone: "clients.form.error.incompletePhone"
        case .saveFailed: "clients.form.error.saveFailed"
        }
    }
}
