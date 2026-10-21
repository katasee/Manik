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

    func url(message: String) -> URL? {
        guard case .sms(let phone) = self else { return url }

        let body = message.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""

        return URL(string: "sms:" + phone + "&body=" + body)
    }
}
