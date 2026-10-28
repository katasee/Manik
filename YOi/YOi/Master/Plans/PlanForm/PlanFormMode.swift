import SwiftUI

enum PlanFormMode: Identifiable {
    case add
    case edit(EventTemplate)

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let template): template.id ?? "edit"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .add: "plans.add.title"
        case .edit: "plans.edit.title"
        }
    }
}
