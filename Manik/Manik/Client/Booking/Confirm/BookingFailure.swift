import SwiftUI

enum BookingFailure {
    case slotTaken
    case expired
    case generic

    var messageKey: LocalizedStringKey {
        switch self {
        case .slotTaken: "booking.error.slotTaken"
        case .expired: "booking.error.expired"
        case .generic: "booking.error.generic"
        }
    }
}
