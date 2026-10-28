import FirebaseFirestore

struct MonthlySummary: Identifiable, Codable {
    @DocumentID var id: String?
    var revenue: Int
    var visits: Int
    var clients: Int
    var windows: Int
    var bookedWindows: Int
}
