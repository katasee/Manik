import FirebaseFirestore

final class FirestoreServiceRepository: ServiceRepository {
    private let db = Firestore.firestore()

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            let listener = db.collection("services").addSnapshotListener { snapshot, _ in
                let services = snapshot?.documents.compactMap { try? $0.data(as: Service.self) } ?? []
                continuation.yield(services)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func add(_ service: Service) async throws {
        _ = try db.collection("services").addDocument(from: service)
    }

    func update(_ service: Service) async throws {
        guard let id = service.id else { return }
        try db.collection("services").document(id).setData(from: service)
    }

    func delete(id: String) async throws {
        try await db.collection("services").document(id).delete()
    }
}
