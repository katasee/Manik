import Foundation

#if DEBUG
final class FakeUserRepository: UserRepository {
    private var profiles: [String: UserProfile]

    init(profiles: [String: UserProfile]) {
        self.profiles = profiles
    }

    func fetchProfile(uid: String) async throws -> UserProfile {
        guard let profile = profiles[uid] else { throw missingProfile(uid: uid) }

        return profile
    }

    func updateProfile(uid: String, edit: ProfileEdit) async throws {
        guard var profile = profiles[uid] else { throw missingProfile(uid: uid) }

        profile.name = edit.name
        profile.phone = edit.phone
        profile.instagram = edit.instagram
        profile.telegram = edit.telegram
        profiles[uid] = profile
    }

    private func missingProfile(uid: String) -> NSError {
        NSError(
            domain: "FakeUserRepository",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "No profile for uid \(uid)"]
        )
    }
}
#endif
