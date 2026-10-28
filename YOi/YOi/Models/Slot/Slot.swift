import FirebaseFirestore

struct Slot: Identifiable, Codable {
    @DocumentID var id: String?
    var date: String
    var time: String
    var clientId: String?
    var serviceId: String?
    var serviceName: String?
    var servicePrice: Int?
}
