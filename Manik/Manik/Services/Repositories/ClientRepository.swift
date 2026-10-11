protocol ClientRepository {
    func observeClients() -> AsyncStream<[Client]>
    func add(_ client: Client) async throws
    func update(_ client: Client) async throws
    func delete(id: String) async throws
}
