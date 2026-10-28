import Foundation

enum RescheduleMessage {
    static func text(date: String, time: String) -> String {
        let day = DateFormat.date.date(from: date).map { DateFormat.messageDay.string(from: $0) } ?? date
        let hour = DateFormat.time.date(from: time).map { DateFormat.messageTime.string(from: $0) } ?? time

        return String(localized: "schedule.reschedule.message \(day) \(hour)")
    }
}
