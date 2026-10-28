import Foundation

enum PhoneFormat {
    static let countryCode = "+48"
    static let nationalLength = 9

    private static let countryDigits = "48"

    private static let groupSizes = [3, 3, 3]

    static func national(from text: String) -> String {
        var digits = text.filter(\.isNumber)

        if digits.count == nationalLength + countryDigits.count, digits.hasPrefix(countryDigits) {
            digits.removeFirst(countryDigits.count)
        }

        return String(digits.prefix(nationalLength))
    }

    static func isComplete(_ national: String) -> Bool {
        national.count == nationalLength
    }

    static func stored(national: String) -> String? {
        guard isComplete(national) else { return nil }

        return countryCode + national
    }

    static func grouped(_ national: String) -> String {
        var rest = Substring(national)

        let groups = groupSizes.compactMap { size -> String? in
            let group = rest.prefix(size)
            rest = rest.dropFirst(size)

            return group.isEmpty ? nil : String(group)
        }

        return groups.joined(separator: " ")
    }

    static func display(_ stored: String?) -> String? {
        guard let stored else { return nil }

        let national = national(from: stored)

        guard stored == countryCode + national, isComplete(national) else { return stored }

        return countryCode + " " + grouped(national)
    }
}
