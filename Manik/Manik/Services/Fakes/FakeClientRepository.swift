import Foundation

#if DEBUG
final class FakeClientRepository: ClientRepository {
    private var clients: [Client]
    private var continuations: [UUID: AsyncStream<[Client]>.Continuation] = [:]

    init(clients: [Client] = []) {
        self.clients = clients
    }

    func observeClients() -> AsyncStream<[Client]> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(clients)
        }
    }

    func add(_ client: Client) async throws {
        var stored = client
        stored.id = client.id ?? UUID().uuidString
        clients.append(stored)
        broadcast()
    }

    func update(_ client: Client) async throws {
        guard
            let id = client.id,
            let index = clients.firstIndex(where: { $0.id == id })
        else { return }

        clients[index] = client
        broadcast()
    }

    func delete(id: String) async throws {
        clients.removeAll { $0.id == id }
        broadcast()
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(clients)
        }
    }
}
#endif
