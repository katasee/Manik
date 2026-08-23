import FirebaseFirestore

final class FirestoreUserRepository: UserRepository {
    private let db = Firestore.firestore()

    func fetchProfile(uid: String) async throws -> UserProfile {
        try await db.collection("users").document(uid).getDocument(as: UserProfile.self)
    }
}
