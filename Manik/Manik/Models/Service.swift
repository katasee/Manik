import FirebaseFirestore

struct Service: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var durationMinutes: Int
    var price: Double
}
