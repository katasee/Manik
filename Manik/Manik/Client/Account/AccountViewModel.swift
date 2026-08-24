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
    private let onProfileUpdated: (UserProfile) -> Void

    private var blocks: [Block] = [] {
        didSet { rebuildStats() }
    }

    init(
        profile: UserProfile,
        userRepository: UserRepository = FirestoreUserRepository(),
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        onProfileUpdated: @escaping (UserProfile) -> Void
    ) {
        self.profile = profile
        self.userRepository = userRepository
        self.blockRepository = blockRepository
        self.onProfileUpdated = onProfileUpdated
    }

    func makeProfileFormViewModel() -> ProfileFormViewModel {
        ProfileFormViewModel(
            profile: profile,
            userRepository: userRepository
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

    private func rebuildStats() {
        stats = AccountStats.make(
            blocks: blocks,
            clientId: profile.uid,
            now: .now
        )
    }
}
