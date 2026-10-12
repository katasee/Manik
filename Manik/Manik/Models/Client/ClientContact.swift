import Foundation

enum ClientContact: Hashable, Identifiable {
    case instagramProfile(handle: String)
    case call(phone: String)
    case sms(phone: String)

    var id: Self { self }

    var url: URL? {
        switch self {
        case .instagramProfile(let handle): URL(string: "https://instagram.com/" + handle)
        case .call(let phone): URL(string: "tel:" + phone)
        case .sms(let phone): URL(string: "sms:" + phone)
        }
    }
}
