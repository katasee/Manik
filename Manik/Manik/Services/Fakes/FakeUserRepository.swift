import Foundation

#if DEBUG
struct FakeUserRepository: UserRepository {
    let profiles: [String: UserProfile]

    func fetchProfile(uid: String) async throws -> UserProfile {
        guard let profile = profiles[uid] else {
            throw NSError(
                domain: "FakeUserRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No profile for uid \(uid)"]
            )
        }

        return profile
    }
}
#endif
