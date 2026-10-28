import Foundation

#if DEBUG
enum ProfilePreviewData {
    static let password = "secret1"

    static let profile = UserProfile(uid: "preview-master", name: "Марія", email: "maria@example.com")
}
#endif
