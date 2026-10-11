import SwiftUI

enum ClientFormMode {
    case add
    case edit

    var titleKey: LocalizedStringKey {
        switch self {
        case .add: "clients.add.title"
        case .edit: "clients.edit.title"
        }
    }

    var submitKey: LocalizedStringKey {
        switch self {
        case .add: "clients.add.submit"
        case .edit: "clients.edit.submit"
        }
    }
}
