import SwiftUI

extension BlockStatus {
    var accentColor: Color {
        switch self {
        case .available: Color.statusAvailable
        case .pending: Color.statusPending
        case .confirmed: Color.statusConfirmed
        }
    }

    var textKey: LocalizedStringKey {
        switch self {
        case .available: "schedule.status.available"
        case .pending: "schedule.status.pending"
        case .confirmed: "schedule.status.confirmed"
        }
    }
}
