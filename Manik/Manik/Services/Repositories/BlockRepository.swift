protocol BlockRepository {
    func observeBlocks() -> AsyncStream<[Block]>
    func addBlock(_ block: Block) async throws
    func confirm(blockId: String) async throws
    func decline(blockId: String) async throws
    func cancel(blockId: String) async throws
    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws
}
