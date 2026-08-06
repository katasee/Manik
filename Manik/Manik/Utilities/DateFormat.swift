import Foundation

enum DateFormat {
    static let date = storageFormatter("yyyy-MM-dd")
    static let time = storageFormatter("HH:mm")
    static let dayNumber = displayFormatter("d")
    static let weekdayLetter = displayFormatter("EEEEE")
    static let monthYear = displayFormatter("LLLL y")

    static let salonTimeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current

    static func hourLabel(for hour: Int) -> String {
        let components = DateComponents(
            year: 2000,
            month: 1,
            day: 1,
            hour: hour,
            minute: 0
        )

        guard let date = salonCalendar.date(from: components) else { return "" }

        return clockTime.string(from: date)
    }

    static func displayTime(_ storageTime: String) -> String {
        guard let date = time.date(from: storageTime) else { return storageTime }

        return clockTime.string(from: date)
    }

    private static let clockTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = salonTimeZone
        formatter.setLocalizedDateFormatFromTemplate("jmm")
        return formatter
    }()

    private static let salonCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = salonTimeZone
        return calendar
    }()

    private static func storageFormatter(_ format: String) -> DateFormatter {
        formatter(format, locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func displayFormatter(_ format: String) -> DateFormatter {
        formatter(format, locale: .current)
    }

    private static func formatter(_ format: String, locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = salonTimeZone
        return formatter
    }
}
