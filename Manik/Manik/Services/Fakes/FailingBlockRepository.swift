import Foundation

#if DEBUG
final class FailingBlockRepository: BlockRepository {
    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { $0.yield([]) }
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
