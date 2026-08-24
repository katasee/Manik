import Foundation

extension Block {
    var endsAt: Date? {
        DateFormat.dateTime.date(from: "\(date) \(endTime)")
    }
}
