#if DEBUG
struct FakeServiceRepository: ServiceRepository {
    let services: [Service]

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            continuation.yield(services)
            continuation.finish()
        }
    }

    func add(_ service: Service) async throws {}
    func update(_ service: Service) async throws {}
    func delete(id: String) async throws {}
}
#endif
