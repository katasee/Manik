import Foundation

#if DEBUG
final class FailingBlockRepository: BlockRepository {
    private let blocks: [Block]

    init(blocks: [Block] = []) {
        self.blocks = blocks
    }

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { [blocks] in $0.yield(blocks) }
    }

    func addBlock(_ block: Block) async throws {
        throw BookingError.slotUnavailable
    }

    func deleteBlock(blockId: String) async throws {
        throw BookingError.slotUnavailable
    }

    func confirm(blockId: String) async throws {
        throw BookingError.slotUnavailable
    }

    func decline(blockId: String) async throws {
        throw BookingError.slotUnavailable
    }

    func cancel(blockId: String) async throws {
        throw BookingError.slotUnavailable
    }

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {
        throw BookingError.slotUnavailable
    }
}
#endif
