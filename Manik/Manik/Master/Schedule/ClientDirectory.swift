import Foundation

struct ClientDirectory {
    let isLoaded: Bool
    private let clientsById: [String: Client]

    init(clients: [Client], isLoaded: Bool) {
        self.isLoaded = isLoaded
        clientsById = Dictionary(
            clients.compactMap { client in client.id.map { ($0, client) } },
            uniquingKeysWith: { first, _ in first }
        )
    }

    var clients: [Client] {
        Array(clientsById.values)
    }

    func name(for clientId: String) -> String {
        guard isLoaded else { return "" }

        return clientsById[clientId]?.displayName ?? String(localized: "schedule.slot.clientDeleted")
    }
}
