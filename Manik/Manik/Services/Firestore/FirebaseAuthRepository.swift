import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthRepository: AuthRepository {
    private let db = Firestore.firestore()

    var currentUserId: String? { Auth.auth().currentUser?.uid }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let profile = UserProfile(
            uid: result.user.uid,
            role: .client,
            name: name,
            email: email
        )
        let encoded = try Firestore.Encoder().encode(profile)
        try await db.collection("users")
            .document(result.user.uid)
            .setData(encoded)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func fetchProfile() async throws -> UserProfile {
        guard let uid = currentUserId else {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not signed in"]
            )
        }
        return try await db.collection("users").document(uid).getDocument(as: UserProfile.self)
    }
}
