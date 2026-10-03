protocol AuthRepository {
    var currentUserId: String? { get }
    func signUp(email: String, password: String, name: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func fetchProfile() async throws -> UserProfile
    func reauthenticate(password: String) async throws
    func updatePassword(to newPassword: String) async throws
    func deleteAccount() async throws
}
