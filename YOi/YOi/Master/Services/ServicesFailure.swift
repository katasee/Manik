import SwiftUI

enum ServicesFailure {
    case update
    case delete

    var titleKey: LocalizedStringKey {
        switch self {
        case .update: "services.alert.updateFailed"
        case .delete: "services.alert.deleteFailed"
        }
    }
}
