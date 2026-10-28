import FirebaseAuth
import FirebaseFirestore

extension Firestore {
    func userCollection(_ name: String) throws -> CollectionReference {
        guard let uid = Auth.auth().currentUser?.uid else { throw AccountError.profileNotFound }

        return collection("users").document(uid).collection(name)
    }
}
