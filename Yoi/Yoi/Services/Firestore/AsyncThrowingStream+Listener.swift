import FirebaseFirestore

extension AsyncThrowingStream where Failure == any Error {
    static func listening<Snapshot>(
        _ register: (@escaping (Snapshot?, (any Error)?) -> Void) throws -> ListenerRegistration,
        read: @escaping (Snapshot) -> Element
    ) -> Self {
        let (stream, continuation) = makeStream(
            of: Element.self,
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
