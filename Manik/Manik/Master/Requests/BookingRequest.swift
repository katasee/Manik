import Foundation

struct BookingRequest: Identifiable {
    let id: String
    let clientName: String
    let serviceName: String
    let dayLabel: String
    let timeRangeLabel: String
    let priceLabel: String?
}
