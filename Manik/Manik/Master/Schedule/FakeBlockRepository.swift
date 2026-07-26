#if DEBUG
struct FakeBlockRepository: BlockRepository {
    var blocks: [Block] = []

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { continuation in
            continuation.yield(blocks)
        }
    }

    func addBlock(_ block: Block) async throws {}
    func confirm(blockId: String) async throws {}
    func decline(blockId: String) async throws {}
    func cancel(blockId: String) async throws {}

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {}
}
#endif
