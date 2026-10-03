import Foundation

#if DEBUG
final class FailingAuthRepository: AuthRepository {
    private let error: AccountError

    init(error: AccountError = .generic) {
        self.error = error
    }

    var currentUserId: String? { "failing-uid" }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {
        throw error
    }

    func signIn(email: String, password: String) async throws {
        throw error
    }

    func signOut() throws {
        throw error
    }

    func fetchProfile() async throws -> UserProfile {
        throw error
    }

    func reauthenticate(password: String) async throws {
        throw error
    }

    func updatePassword(to newPassword: String) async throws {
        throw error
    }

    func deleteAccount() async throws {
        throw error
    }
}
#endif
