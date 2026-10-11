import FirebaseFirestore

final class FirestoreClientRepository: ClientRepository {
    private let db = Firestore.firestore()

    func observeClients() -> AsyncStream<[Client]> {
        AsyncStream { continuation in
            guard let clients = try? db.userCollection("clients") else {
                continuation.finish()
                return
            }

            let listener = clients.addSnapshotListener { snapshot, _ in
                let clients = snapshot?.documents.compactMap { try? $0.data(as: Client.self) } ?? []
                continuation.yield(clients)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func add(_ client: Client) async throws {
        let encoded = try Firestore.Encoder().encode(client)
        _ = try await db.userCollection("clients").addDocument(data: encoded)
    }

    func update(_ client: Client) async throws {
        guard let id = client.id else {
            throw NSError(
                domain: "ClientRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a client without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(client)
        try await db.userCollection("clients").document(id).setData(encoded)
    }

    func delete(id: String) async throws {
        try await db.userCollection("clients").document(id).delete()
    }
}
