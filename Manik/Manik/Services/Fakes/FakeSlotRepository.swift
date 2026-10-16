import Foundation
import Synchronization

#if DEBUG
final class FakeSlotRepository: SlotRepository {
    private struct State {
        var slots: [Slot]
        var observers: [UUID: ([Slot]) -> Void] = [:]
    }

    private let state: Mutex<State>

    init(slots: [Slot] = []) {
        state = Mutex(State(slots: slots))
    }

    func observeSlots() -> AsyncThrowingStream<[Slot], Error> {
        let key = UUID()
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: [Slot].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.observers[key] = nil }
        }

        state.withLock { state in
            state.observers[key] = { continuation.yield($0) }
            continuation.yield(state.slots)
        }

        return stream
    }

    func add(_ slots: [Slot]) throws {
        change { stored in
            for slot in slots {
                let id = Slot.documentId(date: slot.date, time: slot.time)

                guard stored.contains(where: { $0.id == id }) == false else { continue }

                stored.append(Slot(id: id, date: slot.date, time: slot.time))
            }
        }
    }

    func delete(id: String) throws {
        change { $0.removeAll { $0.id == id } }
    }

    private func change(_ apply: (inout [Slot]) -> Void) {
        state.withLock { state in
            apply(&state.slots)

            for observer in state.observers.values {
                observer(state.slots)
            }
        }
    }
}
#endif
