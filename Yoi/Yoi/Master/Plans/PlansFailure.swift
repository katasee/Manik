import SwiftUI

enum PlansFailure {
    case save
    case delete

    var titleKey: LocalizedStringKey {
        switch self {
        case .save: "plans.alert.saveFailed"
        case .delete: "plans.alert.deleteFailed"
        }
    }
}
