import Foundation

#if DEBUG
final class FakeAuthRepository: AuthRepository {
    private let profile: UserProfile
    private var password: String
    private var isDeleted = false

    init(profile: UserProfile, password: String) {
        self.profile = profile
        self.password = password
    }

    var currentUserId: String? { isDeleted ? nil : profile.uid }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {}

    func signIn(email: String, password: String) async throws {}

    func signOut() throws {}

    func fetchProfile() async throws -> UserProfile {
        guard isDeleted == false else { throw AccountError.profileNotFound }

        return profile
    }

    func reauthenticate(password: String) async throws {
        guard password == self.password else { throw AccountError.wrongPassword }
    }

    func updatePassword(to newPassword: String) async throws {
        password = newPassword
    }

    func deleteAccount() async throws {
        isDeleted = true
    }
}
#endif
