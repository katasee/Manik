import SwiftUI

struct ClientContactMenu<Label: View>: View {
    @Environment(\.openURL) private var openURL

    let contacts: [ClientContact]
    @ViewBuilder let label: Label

    init(contacts: [ClientContact], @ViewBuilder label: () -> Label) {
        self.contacts = contacts
        self.label = label()
    }

    var body: some View {
        Menu {
            ForEach(contacts) { contact in
                let item = ClientContactItem(contact: contact)

                Button(item.titleKey, systemImage: item.systemImage) {
                    open(contact)
                }
            }
        } label: {
            label
        }
    }

    private func open(_ contact: ClientContact) {
        guard let url = contact.url else { return }

        openURL(url)
    }
}

#if DEBUG
#Preview {
    ClientContactMenu(
        contacts: [
            .instagramProfile(handle: "olya.nails"),
            .call(phone: "+48600123456"),
            .sms(phone: "+48600123456")
        ]
    ) {
        RoundIconLabel(systemImage: "bubble.left")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
#endif
