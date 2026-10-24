import SwiftUI

struct RescheduleNotifyStep: View {
    let message: String
    let contacts: [ClientContact]
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            messageCard

            ClientMessageContacts(contacts: contacts, message: message)

            doneButton
        }
        .onAppear(perform: copyMessage)
    }

    private var messageCard: some View {
        Text(verbatim: message)
            .font(.elmsSans(.regular, ScheduleMetrics.Size.sendText))
            .foregroundStyle(Color.ink)
            .lineSpacing(ScheduleMetrics.Spacing.sendLineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(
                padding: ScheduleMetrics.Spacing.sendCardPadding,
                cornerRadius: ScheduleMetrics.Size.sendCardCornerRadius
            )
    }

    private var doneButton: some View {
        HStack {
            Spacer()

            PopupDismissButton(titleKey: "common.action.done", action: onDone)
        }
    }

    private func copyMessage() {
        UIPasteboard.general.string = message
    }
}

#if DEBUG
#Preview {
    RescheduleNotifyStep(
        message: RescheduleMessage.text(date: "2026-10-24", time: "14:00"),
        contacts: ClientsPreviewData.clients[0].contacts,
        onDone: {}
    )
    .padding()
    .background(Color.card)
}
#endif
