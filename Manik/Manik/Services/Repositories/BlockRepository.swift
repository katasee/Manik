struct BookedService {
    let id: String
    let name: String
    let price: Int
}

protocol BlockRepository {
    func observeBlocks() -> AsyncStream<[Block]>
    func addBlock(_ block: Block) async throws
    func deleteBlock(blockId: String) async throws
    func confirm(blockId: String) async throws
    func decline(blockId: String) async throws
    func cancel(blockId: String) async throws
    func book(
        blockId: String,
        clientId: String,
        service: BookedService
    ) async throws
}
