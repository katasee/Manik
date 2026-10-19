import SwiftUI

struct SendScheduleContactsStep: View {
    let recipient: ClientItem
    let onOpen: (ClientContact) -> Void
    let onBack: () -> Void

    private var contacts: [ClientContact] {
        recipient.contacts.filter { contact in
            if case .call = contact { false } else { true }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(
                title: recipient.title,
                subtitle: String(localized: "schedule.send.contacts.subtitle")
            )

            if contacts.isEmpty {
                ClientNoContactsPlate()
            } else {
                VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
                    ForEach(contacts) { contact in
                        let item = ClientContactItem(contact: contact)

                        Button {
                            onOpen(contact)
                        } label: {
                            BookingActionLabel(titleKey: item.titleKey, systemImage: item.systemImage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PopupDismissButton(titleKey: "common.action.back", action: onBack)
        }
    }
}

#if DEBUG
#Preview {
    SendScheduleContactsStep(
        recipient: ClientItem(client: ClientsPreviewData.clients[0]),
        onOpen: { _ in },
        onBack: {}
    )
    .padding()
    .background(Color.card)
}
#endif
