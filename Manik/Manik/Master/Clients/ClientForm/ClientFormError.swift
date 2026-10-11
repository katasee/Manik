import SwiftUI

struct ClientFormErrors {
    var instagram: ClientFormError?
    var phone: ClientFormError?
}

enum ClientFormError {
    case missingNameOrHandle
    case duplicateHandle
    case incompletePhone

    var messageKey: LocalizedStringKey {
        switch self {
        case .missingNameOrHandle: "clients.form.error.missingNameOrHandle"
        case .duplicateHandle: "clients.form.error.duplicateHandle"
        case .incompletePhone: "clients.form.error.incompletePhone"
        }
    }
}
