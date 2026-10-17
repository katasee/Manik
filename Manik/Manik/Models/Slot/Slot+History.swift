import Foundation

extension Slot {
    static let historyMonths = 3

    static func historyStartDate(now: Date) -> Date {
        DateFormat.salonCalendar.date(byAdding: .month, value: -historyMonths, to: now) ?? now
    }

    static func historyStart(now: Date) -> String {
        DateFormat.date.string(from: historyStartDate(now: now))
    }
}
