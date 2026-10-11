import FirebaseFirestore

final class FirestoreClientRepository: ClientRepository {
    private let db = Firestore.firestore()

    func observeClients() -> AsyncThrowingStream<[Client], Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: [Client].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        do {
            let listener = try db.userCollection("clients").addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }

                let clients = snapshot?.documents.compactMap { try? $0.data(as: Client.self) } ?? []
                continuation.yield(clients)
            }
            continuation.onTermination = { _ in listener.remove() }
        } catch {
            continuation.finish(throwing: error)
        }

        return stream
    }

    func add(_ client: Client) async throws {
        let encoded = try Firestore.Encoder().encode(client)
        _ = try db.userCollection("clients").addDocument(data: encoded, completion: nil)
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
