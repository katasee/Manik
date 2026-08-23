protocol UserRepository {
    func fetchProfile(uid: String) async throws -> UserProfile
}
