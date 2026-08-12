import Foundation

extension Block {
    var startsAt: Date? {
        DateFormat.dateTime.date(from: "\(date) \(startTime)")
    }
}
