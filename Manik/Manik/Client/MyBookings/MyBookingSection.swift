import Foundation

struct MyBookingSection: Identifiable {
    enum Kind {
        case upcoming
        case past
    }

    let kind: Kind
    let bookings: [MyBooking]

    var id: Kind { kind }
}
