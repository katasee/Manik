import Foundation

struct MyBooking: Identifiable {
    let id: String
    let serviceName: String
    let dayLabel: String
    let timeRangeLabel: String
    let priceLabel: String?
    let status: BlockStatus
    let isPast: Bool
}
