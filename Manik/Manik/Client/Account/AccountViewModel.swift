import Foundation
import Observation

@MainActor
@Observable
final class AccountViewModel {
    private(set) var profile: UserProfile
    private(set) var stats: AccountStats = .empty
    private(set) var hasLoadedStats = false

    private let userRepository: UserRepository
    private let blockRepository: BlockRepository
    private let authRepository: AuthRepository
    private let onProfileUpdated: (UserProfile) -> Void

    private var blocks: [Block] = [] {
        didSet { rebuildStats() }
    }

    init(
        profile: UserProfile,
        userRepository: UserRepository = FirestoreUserRepository(),
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        authRepository: AuthRepository = FirebaseAuthRepository(),
        onProfileUpdated: @escaping (UserProfile) -> Void
    ) {
        self.profile = profile
        self.userRepository = userRepository
        self.blockRepository = blockRepository
        self.authRepository = authRepository
        self.onProfileUpdated = onProfileUpdated
    }

    func makeProfileFormViewModel() -> ProfileFormViewModel {
        ProfileFormViewModel(
            profile: profile,
            userRepository: userRepository
        )
    }

    func makeChangePasswordViewModel() -> ChangePasswordViewModel {
        ChangePasswordViewModel(authRepository: authRepository)
    }

    func makeDeleteAccountViewModel() -> DeleteAccountViewModel {
        DeleteAccountViewModel(
            uid: profile.uid,
            upcomingBookingIds: upcomingBookingIds(now: .now),
            authRepository: authRepository,
            userRepository: userRepository,
            blockRepository: blockRepository
        )
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
            hasLoadedStats = true
        }
    }

    func apply(_ profile: UserProfile) {
        self.profile = profile
        onProfileUpdated(profile)
    }

    private func upcomingBookingIds(now: Date) -> [String] {
        blocks
            .filter { $0.clientId == profile.uid }
            .filter { $0.status == .pending || $0.status == .confirmed }
            .filter { $0.isUpcoming(now: now) }
            .compactMap(\.id)
    }

    private func rebuildStats() {
        stats = AccountStats.make(
            blocks: blocks,
            clientId: profile.uid,
            now: .now
        )
    }
}
