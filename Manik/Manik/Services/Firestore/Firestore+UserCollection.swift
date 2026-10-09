import FirebaseAuth
import FirebaseFirestore

extension Firestore {
    /// `users/{uid}/<name>` for the signed-in master: every master's data lives under her own
    /// user document, and the rules let only her read it.
    func userCollection(_ name: String) throws -> CollectionReference {
        guard let uid = Auth.auth().currentUser?.uid else { throw AccountError.profileNotFound }

        return collection("users").document(uid).collection(name)
    }
}
