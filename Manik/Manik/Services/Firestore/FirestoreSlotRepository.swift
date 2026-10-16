import FirebaseFirestore

final class FirestoreSlotRepository: SlotRepository {
    private let db = Firestore.firestore()

    func observeSlots() -> AsyncThrowingStream<[Slot], Error> {
        .listening { try db.userCollection("slots").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: Slot.self) }
        }
    }

    func add(_ slots: [Slot]) throws {
        let collection = try db.userCollection("slots")
        let batch = db.batch()

        for slot in slots {
            batch.setData(
                ["date": slot.date, "time": slot.time],
                forDocument: collection.document(Slot.documentId(date: slot.date, time: slot.time)),
                merge: true
            )
        }

        batch.commit(completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("slots").document(id).delete(completion: nil)
    }
}
