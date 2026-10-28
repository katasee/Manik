import FirebaseFirestore
import Foundation

struct Client: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String?
    var instagram: String?
    var phone: String?
    var createdAt: Date
    var lastBookedAt: Date?
}
