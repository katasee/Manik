import Foundation

struct ClientCard {
    let title: String
    let initial: String
    let details: String?
    let contacts: [ClientContact]

    init(client: Client) {
        let item = ClientItem(client: client)

        title = item.title
        initial = item.initial
        contacts = item.contacts
        details = Self.makeDetails(for: client)
    }

    private static func makeDetails(for client: Client) -> String? {
        let parts = [client.instagramNickname, PhoneFormat.display(client.phone)].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
