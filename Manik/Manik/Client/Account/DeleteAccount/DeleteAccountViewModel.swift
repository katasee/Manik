import Foundation
import Observation

@MainActor
@Observable
final class DeleteAccountViewModel {
    var password = ""

    let upcomingCount: Int

    private(set) var isDeleting = false
    private(set) var failure: PasswordFailure?

    private var cancelledBlockIds: Set<String> = []

    private let uid: String
    private let upcomingBookingIds: [String]
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let blockRepository: BlockRepository

    init(
        uid: String,
        upcomingBookingIds: [String],
        authRepository: AuthRepository,
        userRepository: UserRepository,
        blockRepository: BlockRepository
    ) {
        self.uid = uid
        self.upcomingBookingIds = upcomingBookingIds
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.blockRepository = blockRepository
        upcomingCount = upcomingBookingIds.count
    }

    var canSubmit: Bool {
        password.isEmpty == false
    }

    func delete() async -> Bool {
        guard isDeleting == false, canSubmit else { return false }

        isDeleting = true
        failure = nil
        defer { isDeleting = false }

        do {
            try await authRepository.reauthenticate(password: password)

            for blockId in upcomingBookingIds where cancelledBlockIds.contains(blockId) == false {
                try await blockRepository.cancel(blockId: blockId)
                cancelledBlockIds.insert(blockId)
            }

            try await userRepository.deleteProfile(uid: uid)
            try await authRepository.deleteAccount()

            return true
        } catch let error as AccountError {
            failure = PasswordFailure(error)

            return false
        } catch {
            failure = .generic

            return false
        }
    }
}
