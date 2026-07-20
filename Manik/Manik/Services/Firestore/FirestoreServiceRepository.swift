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
        let encoded = try Firestore.Encoder().encode(service)
        _ = try await db.collection("services").addDocument(data: encoded)
    }

    func update(_ service: Service) async throws {
        guard let id = service.id else {
            throw NSError(
                domain: "ServiceRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a service without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(service)
        try await db.collection("services").document(id).setData(encoded)
    }

    func delete(id: String) async throws {
        try await db.collection("services").document(id).delete()
    }
}
