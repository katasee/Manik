import FirebaseFirestore

final class FirestoreBlockRepository: BlockRepository {
    private let db = Firestore.firestore()

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { continuation in
            guard let blocks = try? db.userCollection("blocks") else {
                continuation.finish()
                return
            }

            let listener = blocks.addSnapshotListener { snapshot, _ in
                let blocks = snapshot?.documents.compactMap { try? $0.data(as: Block.self) } ?? []
                continuation.yield(blocks)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func addBlock(_ block: Block) async throws {
        let encoded = try Firestore.Encoder().encode(block)
        _ = try await db.userCollection("blocks").addDocument(data: encoded)
    }

    func deleteBlock(blockId: String) async throws {
        try await db.userCollection("blocks").document(blockId).delete()
    }

    func confirm(blockId: String) async throws {
        try await db.userCollection("blocks").document(blockId).updateData([
            "status": BlockStatus.confirmed.rawValue
        ])
    }

    func decline(blockId: String) async throws {
        try await db.userCollection("blocks").document(blockId).updateData([
            "status": BlockStatus.available.rawValue,
            "clientId": FieldValue.delete(),
            "bookedServiceId": FieldValue.delete(),
            "bookedServiceName": FieldValue.delete(),
            "bookedServicePrice": FieldValue.delete()
        ])
    }

    func cancel(blockId: String) async throws {
        try await db.userCollection("blocks").document(blockId).updateData([
            "status": BlockStatus.available.rawValue,
            "clientId": FieldValue.delete(),
            "bookedServiceId": FieldValue.delete(),
            "bookedServiceName": FieldValue.delete(),
            "bookedServicePrice": FieldValue.delete()
        ])
    }
}
