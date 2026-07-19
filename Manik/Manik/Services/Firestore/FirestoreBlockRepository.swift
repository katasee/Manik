import FirebaseFirestore

final class FirestoreBlockRepository: BlockRepository {
    private let db = Firestore.firestore()

    func observeBlocks() -> AsyncStream<[Block]> {
        AsyncStream { continuation in
            let listener = db.collection("blocks").addSnapshotListener { snapshot, _ in
                let blocks = snapshot?.documents.compactMap { try? $0.data(as: Block.self) } ?? []
                continuation.yield(blocks)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func addBlock(_ block: Block) async throws {
        _ = try db.collection("blocks").addDocument(from: block)
    }

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {
        try await db.collection("blocks").document(blockId).updateData([
            "status": BlockStatus.pending.rawValue,
            "clientId": clientId,
            "bookedServiceId": bookedServiceId
        ])
    }

    func confirm(blockId: String) async throws {
        try await db.collection("blocks").document(blockId).updateData([
            "status": BlockStatus.confirmed.rawValue
        ])
    }

    func decline(blockId: String) async throws {
        try await db.collection("blocks").document(blockId).updateData([
            "status": BlockStatus.available.rawValue,
            "clientId": FieldValue.delete(),
            "bookedServiceId": FieldValue.delete()
        ])
    }

    func cancel(blockId: String) async throws {
        try await db.collection("blocks").document(blockId).updateData([
            "status": BlockStatus.available.rawValue,
            "clientId": FieldValue.delete(),
            "bookedServiceId": FieldValue.delete()
        ])
    }
}
