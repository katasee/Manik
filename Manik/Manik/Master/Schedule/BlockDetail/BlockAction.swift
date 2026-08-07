import SwiftUI

struct BlockActionConfirmation {
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
}

enum BlockAction: String, Identifiable {
    case confirm
    case decline
    case cancelBooking

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .confirm: "schedule.action.confirm"
        case .decline: "schedule.action.decline"
        case .cancelBooking: "schedule.action.cancelBooking"
        }
    }

    var color: Color {
        switch self {
        case .confirm: Color.statusConfirmed
        case .decline, .cancelBooking: Color.destructive
        }
    }

    var confirmation: BlockActionConfirmation? {
        switch self {
        case .confirm:
            nil
        case .decline:
            BlockActionConfirmation(
                titleKey: "schedule.confirm.decline.title",
                messageKey: "schedule.confirm.decline.message"
            )
        case .cancelBooking:
            BlockActionConfirmation(
                titleKey: "schedule.confirm.cancelBooking.title",
                messageKey: "schedule.confirm.cancelBooking.message"
            )
        }
    }
}
