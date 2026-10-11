import Foundation

extension Client {
    private static let phoneQueryCharacters = Set(" +-()")

    func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.isEmpty == false else { return true }

        return nameMatches(trimmed) || instagramMatches(trimmed) || phoneMatches(trimmed)
    }

    private func nameMatches(_ query: String) -> Bool {
        name?.localizedStandardContains(query) ?? false
    }

    private func instagramMatches(_ query: String) -> Bool {
        guard let instagram else { return false }

        let handle = query.hasPrefix("@") ? String(query.dropFirst()) : query

        return handle.isEmpty || instagram.localizedStandardContains(handle)
    }

    private func phoneMatches(_ query: String) -> Bool {
        guard
            let phone,
            query.allSatisfy({ $0.isNumber || Self.phoneQueryCharacters.contains($0) })
        else { return false }

        let digits = query.filter(\.isNumber)

        return digits.isEmpty == false && phone.filter(\.isNumber).contains(digits)
    }
}
