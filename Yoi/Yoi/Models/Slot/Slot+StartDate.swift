import Foundation

extension Slot {
    var startsAt: Date? {
        DateFormat.dateTime.date(from: "\(date) \(time)")
    }
}
