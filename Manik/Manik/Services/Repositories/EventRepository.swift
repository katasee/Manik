protocol EventRepository {
    func observeEvents() -> AsyncThrowingStream<[PlanEvent], Error>
    func add(_ events: [PlanEvent]) throws
    func delete(id: String) throws
}
