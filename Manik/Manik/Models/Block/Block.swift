import FirebaseFirestore

enum BlockStatus: String, Codable {
    case available
    case pending
    case confirmed
}

struct Block: Identifiable, Codable {
    @DocumentID var id: String?
    var date: String
    var startTime: String
    var endTime: String
    var offeredServiceIds: [String]
    var bookedServiceId: String?
    var status: BlockStatus
    var clientId: String?
}
