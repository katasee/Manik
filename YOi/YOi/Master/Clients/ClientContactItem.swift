import SwiftUI

struct ClientContactItem {
    let titleKey: LocalizedStringKey
    let systemImage: String

    init(contact: ClientContact) {
        switch contact {
        case .instagramProfile:
            titleKey = "clients.contact.instagramProfile"
            systemImage = "camera"
        case .call:
            titleKey = "clients.contact.call"
            systemImage = "phone"
        case .sms:
            titleKey = "clients.contact.sms"
            systemImage = "message"
        }
    }
}
