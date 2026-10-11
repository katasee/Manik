import Foundation
import Synchronization

#if DEBUG
final class FakeClientRepository: ClientRepository {
    private struct State {
        var clients: [Client]
        var continuations: [UUID: AsyncThrowingStream<[Client], Error>.Continuation] = [:]
    }

    private let state: Mutex<State>

    init(clients: [Client] = []) {
        state = Mutex(State(clients: clients))
    }

    func observeClients() -> AsyncThrowingStream<[Client], Error> {
        let id = UUID()
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: [Client].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.continuations[id] = nil }
        }

        state.withLock { state in
            state.continuations[id] = continuation
            continuation.yield(state.clients)
        }

        return stream
    }

    func add(_ client: Client) async throws {
        var stored = client
        stored.id = client.id ?? UUID().uuidString
        change { $0.append(stored) }
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

    private func change(_ apply: (inout [Client]) -> Void) {
        state.withLock { state in
            apply(&state.clients)

            for continuation in state.continuations.values {
                continuation.yield(state.clients)
            }
        }
    }
}
#endif
