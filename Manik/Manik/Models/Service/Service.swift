import FirebaseFirestore

struct Service: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Int
    var isActive: Bool?

    var isOffered: Bool {
        isActive ?? true
    }
}
