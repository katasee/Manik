import Foundation

enum Role: String, Codable {
    case master
    case client
}

struct UserProfile: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    var role: Role
    var name: String
    var email: String
}
