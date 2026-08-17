import Foundation

struct CancelBookingContext: Identifiable {
    let id: String
    let serviceName: String
    let dayLabel: String
    let timeRangeLabel: String
}
