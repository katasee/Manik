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
        let encoded = try Firestore.Encoder().encode(block)
        _ = try await db.collection("blocks").addDocument(data: encoded)
    }

    func deleteBlock(blockId: String) async throws {
        try await db.collection("blocks").document(blockId).delete()
    }

    func book(
        blockId: String,
        clientId: String,
        bookedServiceId: String
    ) async throws {
        do {
            try await db.collection("blocks").document(blockId).updateData([
                "status": BlockStatus.pending.rawValue,
                "clientId": clientId,
                "bookedServiceId": bookedServiceId
            ])
        } catch let error as NSError where error.isSlotUnavailable {
            throw BookingError.slotUnavailable
        }
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

private extension NSError {
    var isSlotUnavailable: Bool {
        domain == FirestoreErrorDomain && code == FirestoreErrorCode.permissionDenied.rawValue
    }
}
