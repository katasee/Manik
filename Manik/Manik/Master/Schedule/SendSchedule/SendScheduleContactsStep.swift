import SwiftUI

struct SendScheduleContactsStep: View {
    let recipient: ClientItem
    let message: String
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(
                title: recipient.title,
                subtitle: String(localized: "schedule.send.contacts.subtitle")
            )

            ClientMessageContacts(contacts: recipient.contacts, message: message)

            PopupDismissButton(titleKey: "common.action.back", action: onBack)
        }
    }
}

#if DEBUG
#Preview {
    SendScheduleContactsStep(
        recipient: ClientItem(client: ClientsPreviewData.clients[0]),
        message: SchedulePreviewData.sendSchedule.text ?? "",
        onBack: {}
    )
    .padding()
    .background(Color.card)
}
#endif
