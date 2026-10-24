import SwiftUI

struct ClientMessageContacts: View {
    @Environment(\.openURL) private var openURL

    let contacts: [ClientContact]
    let message: String

    var body: some View {
        let messageContacts = contacts.filter(\.canCarryMessage)

        if messageContacts.isEmpty {
            ClientNoContactsPlate()
        } else {
            VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
                ForEach(messageContacts) { contact in
                    let item = ClientContactItem(contact: contact)

                    Button {
                        open(contact)
                    } label: {
                        BookingActionLabel(titleKey: item.titleKey, systemImage: item.systemImage)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func open(_ contact: ClientContact) {
        guard let url = contact.url(message: message) else { return }

        openURL(url)
    }
}

#if DEBUG
#Preview {
    ClientMessageContacts(
        contacts: ClientsPreviewData.clients[0].contacts,
        message: RescheduleMessage.text(date: "2026-10-24", time: "14:00")
    )
    .padding()
    .background(Color.card)
}
#endif
