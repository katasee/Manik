import Foundation

enum DateFormat {
    static let date = formatter("yyyy-MM-dd")
    static let time = formatter("HH:mm")

    static let salonTimeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = salonTimeZone
        return formatter
    }
}
