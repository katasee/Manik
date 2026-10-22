protocol SlotRepository {
    func observeSlots() -> AsyncThrowingStream<[Slot], Error>
    func add(_ slots: [Slot]) throws
    func book(slotId: String, _ booking: SlotBooking) throws
    func clearBooking(slotId: String) throws
    func reschedule(
        slotId: String,
        _ booking: SlotBooking,
        toDate date: String,
        time: String
    ) throws
    func delete(id: String) throws
}
