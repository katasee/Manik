import Foundation

extension Slot {
    static let historyMonths = 3

    static func historyStart(now: Date) -> String {
        let start = DateFormat.salonCalendar.date(byAdding: .month, value: -historyMonths, to: now) ?? now

        return DateFormat.date.string(from: start)
    }
}
