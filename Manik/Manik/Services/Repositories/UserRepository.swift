protocol UserRepository {
    func fetchProfile(uid: String) async throws -> UserProfile
    func updateProfile(uid: String, edit: ProfileEdit) async throws
}
