import Foundation

#if DEBUG
enum AccountPreviewData {
    static let uid = "client-preview"

    static let profile = UserProfile(
        uid: uid,
        role: .client,
        name: "Олена Ковальчук",
        email: "olena@example.com",
        phone: "+48600123456",
        instagram: "olena_nails",
        telegram: "olena"
    )

    static let emptyContactsProfile = UserProfile(
        uid: uid,
        role: .client,
        name: profile.name,
        email: profile.email
    )

    static let stats = AccountStats(
        visitCount: 12,
        favoriteServiceName: "Манікюр + гель-лак"
    )

    static let profiles = [uid: profile]
}
#endif
