import Foundation

extension Client {
    var contacts: [ClientContact] {
        var contacts: [ClientContact] = []

        let handle = Self.normalizedInstagram(instagram ?? "")

        if handle.isEmpty == false {
            contacts.append(.instagramProfile(handle: handle))
        }

        if let phone = dialablePhone {
            contacts += [.call(phone: phone), .sms(phone: phone)]
        }

        return contacts
    }

    private var dialablePhone: String? {
        guard let phone else { return nil }

        let dialable = phone.filter { $0.isNumber || $0 == "+" }

        return dialable.contains(where: \.isNumber) ? dialable : nil
    }
}
