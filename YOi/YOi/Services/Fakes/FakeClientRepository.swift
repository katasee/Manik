import Foundation
import Synchronization

#if DEBUG
final class FakeClientRepository: ClientRepository {
    private struct State {
        var clients: [Client]
        var observers: [UUID: ([Client]) -> Void] = [:]
    }

    private let state: Mutex<State>

    init(clients: [Client] = []) {
        state = Mutex(State(clients: clients))
    }

    func observeClients() -> AsyncThrowingStream<[Client], Error> {
        observe { $0 }
    }

    func observeClient(id: String) -> AsyncThrowingStream<Client?, Error> {
        observe { clients in clients.first { $0.id == id } }
    }

    func add(_ client: Client) async throws -> String {
        var stored = client
        let id = client.id ?? UUID().uuidString
        stored.id = id
        change { $0.append(stored) }

        return id
    }

    func update(_ client: Client) async throws {
        change { clients in
            guard
                let id = client.id,
                let index = clients.firstIndex(where: { $0.id == id })
            else { return }

            clients[index] = client
        }
    }

    func delete(id: String) async throws {
        change { $0.removeAll { $0.id == id } }
    }

    private func observe<Value>(_ read: @escaping ([Client]) -> Value) -> AsyncThrowingStream<Value, Error> {
        let key = UUID()
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: Value.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.observers[key] = nil }
        }

        state.withLock { state in
            state.observers[key] = { continuation.yield(read($0)) }
            continuation.yield(read(state.clients))
        }

        return stream
    }

    private func change(_ apply: (inout [Client]) -> Void) {
        state.withLock { state in
            apply(&state.clients)

            for observer in state.observers.values {
                observer(state.clients)
            }
        }
    }
}
#endif
