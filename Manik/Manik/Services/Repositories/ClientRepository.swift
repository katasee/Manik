protocol ClientRepository {
    func observeClients() -> AsyncThrowingStream<[Client], Error>
    func add(_ client: Client) async throws
    func update(_ client: Client) async throws
    func delete(id: String) async throws
}
