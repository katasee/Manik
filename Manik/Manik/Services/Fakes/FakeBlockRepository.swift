import Foundation

#if DEBUG
final class FakeBlockRepository: BlockRepository {
    private var blocks: [Block]
    private var continuations: [UUID: AsyncStream<[Block]>.Continuation] = [:]

    init(blocks: [Block] = []) {
        self.blocks = blocks
    }

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(blocks)
        }
    }

    func addBlock(_ block: Block) async throws {
        var stored = block
        stored.id = block.id ?? UUID().uuidString
        blocks.append(stored)
        broadcast()
    }

    func deleteBlock(blockId: String) async throws {
        blocks.removeAll { $0.id == blockId }
        broadcast()
    }

    func confirm(blockId: String) async throws {
        update(blockId) { $0.status = .confirmed }
    }

    func decline(blockId: String) async throws {
        update(blockId) {
            $0.status = .available
            $0.clientId = nil
            $0.bookedServiceId = nil
        }
    }

    func cancel(blockId: String) async throws {
        update(blockId) {
            $0.status = .available
            $0.clientId = nil
            $0.bookedServiceId = nil
        }
    }

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {
        guard blocks.first(where: { $0.id == blockId })?.status == .available else {
            throw BookingError.slotUnavailable
        }

        update(blockId) {
            $0.status = .pending
            $0.clientId = clientId
            $0.bookedServiceId = bookedServiceId
        }
    }

    private func update(_ blockId: String, _ change: (inout Block) -> Void) {
        guard let index = blocks.firstIndex(where: { $0.id == blockId }) else { return }

        change(&blocks[index])
        broadcast()
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(blocks)
        }
    }
}
#endif
