import Foundation

extension Client {
    var displayName: String {
        presentName ?? instagramNickname ?? ""
    }

    var instagramNickname: String? {
        instagram.map { "@" + $0 }
    }

    private var presentName: String? {
        guard let name, name.isEmpty == false else { return nil }

        return name
    }
}
