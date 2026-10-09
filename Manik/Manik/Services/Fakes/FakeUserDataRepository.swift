import Foundation

#if DEBUG
final class FakeUserDataRepository: UserDataRepository {
    private let error: Error?

    init(error: Error? = nil) {
        self.error = error
    }

    func deleteAllData() async throws {
        if let error { throw error }
    }
}
#endif
