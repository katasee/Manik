import Foundation

struct BookingMonth {
    let start: Date
    let title: String
    let weekdaySymbols: [String]
    let days: [BookingDay]
    let canGoBack: Bool
}
