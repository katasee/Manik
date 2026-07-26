import Foundation

enum DateFormat {
    static let date = storageFormatter("yyyy-MM-dd")
    static let time = storageFormatter("HH:mm")
    static let dayNumber = displayFormatter("d")
    static let weekdayLetter = displayFormatter("EEEEE")
    static let monthYear = displayFormatter("LLLL y")

    static let salonTimeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current

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
