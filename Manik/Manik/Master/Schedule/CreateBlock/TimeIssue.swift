import SwiftUI

enum TimeIssue {
    case endBeforeStart
    case overlap

    var messageKey: LocalizedStringKey {
        switch self {
        case .endBeforeStart: "schedule.createSlot.endBeforeStart"
        case .overlap: "schedule.createSlot.overlap"
        }
    }
}
