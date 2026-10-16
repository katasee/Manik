protocol SlotRepository {
    func observeSlots() -> AsyncThrowingStream<[Slot], Error>
    func add(_ slots: [Slot]) throws
    func delete(id: String) throws
}
