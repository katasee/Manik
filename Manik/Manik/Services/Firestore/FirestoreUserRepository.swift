import FirebaseFirestore

final class FirestoreUserRepository: UserRepository {
    private let db = Firestore.firestore()

    func fetchProfile(uid: String) async throws -> UserProfile {
        try await db.collection("users").document(uid).getDocument(as: UserProfile.self)
    }

    func updateProfile(uid: String, edit: ProfileEdit) async throws {
        var fields: [String: Any] = ["name": edit.name]
        put(edit.phone, at: "phone", into: &fields)
        put(edit.instagram, at: "instagram", into: &fields)
        put(edit.telegram, at: "telegram", into: &fields)

        try await db.collection("users").document(uid).updateData(fields)
    }

    private func put(_ value: String?, at key: String, into fields: inout [String: Any]) {
        if let value {
            fields[key] = value
        } else {
            fields[key] = FieldValue.delete()
        }
    }
}
