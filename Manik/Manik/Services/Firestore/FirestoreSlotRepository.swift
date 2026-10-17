import FirebaseFirestore

final class FirestoreSlotRepository: SlotRepository {
    private let db = Firestore.firestore()

    func observeSlots() -> AsyncThrowingStream<[Slot], Error> {
        .listening {
            try db.userCollection("slots")
                .whereField("date", isGreaterThanOrEqualTo: Slot.historyStart(now: .now))
                .addSnapshotListener($0)
        } read: { snapshot in
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

    func book(slotId: String, _ booking: SlotBooking) throws {
        try db.userCollection("slots").document(slotId).setData(
            [
                "clientId": booking.clientId,
                "serviceId": booking.serviceId ?? FieldValue.delete(),
                "serviceName": booking.serviceName ?? FieldValue.delete(),
                "servicePrice": booking.servicePrice ?? FieldValue.delete()
            ],
            merge: true,
            completion: nil
        )
    }

    func clearBooking(slotId: String) throws {
        try db.userCollection("slots").document(slotId).setData(
            [
                "clientId": FieldValue.delete(),
                "serviceId": FieldValue.delete(),
                "serviceName": FieldValue.delete(),
                "servicePrice": FieldValue.delete()
            ],
            merge: true,
            completion: nil
        )
    }

    func delete(id: String) throws {
        try db.userCollection("slots").document(id).delete(completion: nil)
    }
}
