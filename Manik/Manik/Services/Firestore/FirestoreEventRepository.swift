import FirebaseFirestore

final class FirestoreEventRepository: EventRepository {
    private let db = Firestore.firestore()

    func observeEvents() -> AsyncThrowingStream<[PlanEvent], Error> {
        .listening {
            try db.userCollection("events")
                .whereField("date", isGreaterThanOrEqualTo: Slot.historyStart(now: .now))
                .addSnapshotListener($0)
        } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: PlanEvent.self) }
        }
    }

    func add(_ events: [PlanEvent]) throws {
        let collection = try db.userCollection("events")
        let encoder = Firestore.Encoder()
        let batch = db.batch()

        for event in events {
            batch.setData(try encoder.encode(event), forDocument: collection.document())
        }

        batch.commit(completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("events").document(id).delete(completion: nil)
    }
}
