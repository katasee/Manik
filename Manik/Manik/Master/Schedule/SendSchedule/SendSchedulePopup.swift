import SwiftUI

enum SendScheduleMode {
    case text
    case recipient
    case contacts(ClientItem)
}

struct SendSchedulePopup: View {
    let text: String?
    let clients: [ClientItem]
    let onDismiss: () -> Void

    @State private var mode = SendScheduleMode.text
    @State private var pager: MonthPager
    @State private var searchText = ""

    init(
        now: Date,
        text: String?,
        clients: [ClientItem],
        onDismiss: @escaping () -> Void
    ) {
        self.text = text
        self.clients = clients
        self.onDismiss = onDismiss
        _pager = State(initialValue: MonthPager(showing: now, earliest: now))
    }

    var body: some View {
        PopupContainer(dismissLabel: "common.action.close", onDismiss: onDismiss) { dismiss in
            switch mode {
            case .text:
                textStep

                PopupDismissButton(titleKey: "common.action.close", action: dismiss)
            case .recipient:
                recipientStep
            case .contacts(let recipient):
                contactsStep(recipient)
            }
        }
    }

    private var textStep: some View {
        SendScheduleTextStep(
            monthTitle: monthTitle,
            canGoBack: pager.canGoBack,
            text: text,
            onPrevious: showPreviousMonth,
            onNext: showNextMonth,
            onCopy: {},
            onSend: startSending
        )
    }

    private var recipientStep: some View {
        SendScheduleRecipientStep(
            searchText: $searchText,
            subtitle: monthTitle,
            options: options,
            onPick: pick,
            onBack: back
        )
    }

    private func contactsStep(_ recipient: ClientItem) -> some View {
        SendScheduleContactsStep(
            recipient: recipient,
            onOpen: { _ in },
            onBack: back
        )
    }

    private var monthTitle: String {
        DateFormat.monthYear.string(from: pager.grid.start).capitalized
    }

    private var options: [BookClientOption] {
        guard searchText.isEmpty == false else { return [] }

        return clients.map { client in
            BookClientOption(
                id: client.id,
                title: client.title,
                initial: client.initial,
                isSelected: false
            )
        }
    }

    private func showPreviousMonth() {
        pager.showPrevious()
    }

    private func showNextMonth() {
        pager.showNext()
    }

    private func startSending() {
        mode = .recipient
    }

    private func pick(_ clientId: String) {
        guard let client = clients.first(where: { $0.id == clientId }) else { return }

        mode = .contacts(client)
    }

    private func back() {
        switch mode {
        case .text:
            break
        case .recipient:
            searchText = ""
            mode = .text
        case .contacts:
            mode = .recipient
        }
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            SendSchedulePopup(
                now: .now,
                text: SchedulePreviewData.sendScheduleText,
                clients: ClientsPreviewData.clients.map(ClientItem.init),
                onDismiss: {}
            )
        }
}
#endif
