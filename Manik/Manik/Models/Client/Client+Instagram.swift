import Foundation

extension Client {
    private static let instagramMaxLength = 30

    private static let instagramCharacters = Set("abcdefghijklmnopqrstuvwxyz0123456789._")

    private static let profileHost = "instagram.com/"

    static func normalizedInstagram(_ text: String) -> String {
        let handle = profileHandle(in: text) ?? text
        let allowed = handle.lowercased().filter { instagramCharacters.contains($0) }

        return String(allowed.prefix(instagramMaxLength))
    }

    private static func profileHandle(in text: String) -> String? {
        let lowered = text.lowercased()

        guard let range = lowered.firstRange(of: profileHost) else { return nil }

        let path = lowered[range.upperBound...].split { $0 == "/" || $0 == "?" }

        return path.first.map(String.init) ?? ""
    }
}
