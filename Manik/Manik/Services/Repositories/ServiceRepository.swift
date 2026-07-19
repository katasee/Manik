protocol ServiceRepository {
    func observeServices() -> AsyncStream<[Service]>
    func add(_ service: Service) async throws
    func update(_ service: Service) async throws
    func delete(id: String) async throws
}
