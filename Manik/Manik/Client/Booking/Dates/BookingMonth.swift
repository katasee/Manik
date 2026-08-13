import Foundation

struct BookingMonth: Identifiable, Hashable {
    let start: Date
    let title: String
    let weekdaySymbols: [String]
    let days: [BookingDay]
    let canGoBack: Bool

    var id: Date { start }
}
