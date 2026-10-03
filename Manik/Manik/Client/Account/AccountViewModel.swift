import Foundation
import Observation

@MainActor
@Observable
final class AccountViewModel {
    private(set) var profile: UserProfile
    private(set) var stats: AccountStats

    private let userRepository: UserRepository
    private let onProfileUpdated: (UserProfile) -> Void

    init(
        profile: UserProfile,
        stats: AccountStats = .empty,
        userRepository: UserRepository = FirestoreUserRepository(),
        onProfileUpdated: @escaping (UserProfile) -> Void
    ) {
        self.profile = profile
        self.stats = stats
        self.userRepository = userRepository
        self.onProfileUpdated = onProfileUpdated
    }

    func makeProfileFormViewModel() -> ProfileFormViewModel {
        ProfileFormViewModel(
            profile: profile,
            userRepository: userRepository
        )
    }

    func apply(_ profile: UserProfile) {
        self.profile = profile
        onProfileUpdated(profile)
    }
}
