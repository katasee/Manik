import Foundation

struct ClientItem: Identifiable {
    let id: String
    let title: String
    let initial: String
    let contactLine: String?

    init(client: Client) {
        id = client.id ?? client.createdAt.formatted(.iso8601)
        title = client.displayName
        initial = Self.makeInitial(from: client.displayName)
        contactLine = Self.makeContactLine(from: client)
    }

    private static func makeInitial(from title: String) -> String {
        let letter = title.first { $0.isLetter || $0.isNumber }

        return letter.map { String($0).uppercased() } ?? "?"
    }

    private static func makeContactLine(from client: Client) -> String? {
        let parts = [client.instagramNickname, PhoneFormat.display(client.phone)].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
