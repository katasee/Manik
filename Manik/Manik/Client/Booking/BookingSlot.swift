import Foundation

struct BookingSlot: Identifiable, Hashable {
    let id: String
    let date: String
    let startTime: String

    var startsAt: Date? {
        DateFormat.dateTime.date(from: "\(date) \(startTime)")
    }

    var timeLabel: String {
        DateFormat.displayTime(startTime)
    }

    var dayLabel: String {
        label(with: DateFormat.dayMonth)
    }

    var shortDayLabel: String {
        label(with: DateFormat.dayMonthShort)
    }

    private func label(with formatter: DateFormatter) -> String {
        guard let day = DateFormat.date.date(from: date) else { return date }

        return formatter.string(from: day)
    }
}
