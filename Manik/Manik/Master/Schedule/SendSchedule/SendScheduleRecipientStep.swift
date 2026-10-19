import SwiftUI

struct SendScheduleRecipientStep: View {
    @Binding var searchText: String
    let subtitle: String
    let options: [BookClientOption]
    let onPick: (String) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(title: String(localized: "schedule.send.recipient.title"), subtitle: subtitle)

            SearchField(
                text: $searchText,
                placeholderKey: "schedule.book.search.placeholder",
                focusesOnAppear: true
            )

            if options.isEmpty == false {
                VStack(spacing: ScheduleMetrics.Spacing.bookOptionSpacing) {
                    ForEach(options) { option in
                        BookClientRow(option: option) {
                            onPick(option.id)
                        }
                    }
                }
            }

            PopupDismissButton(titleKey: "common.action.back", action: onBack)
        }
    }
}

#if DEBUG
#Preview {
    SendScheduleRecipientStep(
        searchText: .constant("о"),
        subtitle: "Жовтень 2026",
        options: SchedulePreviewData.options,
        onPick: { _ in },
        onBack: {}
    )
    .padding()
    .background(Color.card)
}
#endif
