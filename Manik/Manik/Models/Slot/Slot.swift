import FirebaseFirestore

struct Slot: Identifiable, Codable {
    @DocumentID var id: String?
    var date: String
    var time: String
    var clientId: String?
}
