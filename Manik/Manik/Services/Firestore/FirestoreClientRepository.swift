import FirebaseFirestore

final class FirestoreClientRepository: ClientRepository {
    private typealias SnapshotHandler<Snapshot> = (Snapshot?, Error?) -> Void

    private let db = Firestore.firestore()

    func observeClients() -> AsyncThrowingStream<[Client], Error> {
        listen { try db.userCollection("clients").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: Client.self) }
        }
    }

    func observeClient(id: String) -> AsyncThrowingStream<Client?, Error> {
        listen { try db.userCollection("clients").document(id).addSnapshotListener($0) } read: { snapshot in
            try? snapshot.data(as: Client.self)
        }
    }

    func add(_ client: Client) async throws {
        let encoded = try Firestore.Encoder().encode(client)
        _ = try db.userCollection("clients").addDocument(data: encoded, completion: nil)
    }

    func update(_ client: Client) throws {
        guard let id = client.id else {
            throw NSError(
                domain: "ClientRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a client without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(client)
        try db.userCollection("clients").document(id).setData(encoded, completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("clients").document(id).delete(completion: nil)
    }

    private func listen<Snapshot, Value>(
        _ register: (@escaping SnapshotHandler<Snapshot>) throws -> ListenerRegistration,
        read: @escaping (Snapshot) -> Value
    ) -> AsyncThrowingStream<Value, Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: Value.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        do {
            let listener = try register { snapshot, error in
                if let snapshot {
                    continuation.yield(read(snapshot))
                } else {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in listener.remove() }
        } catch {
            continuation.finish(throwing: error)
        }

        return stream
    }
}
