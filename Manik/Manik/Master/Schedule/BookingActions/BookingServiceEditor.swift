import SwiftUI

struct BookingServiceEditor: View {
    let chips: [BookServiceChip]
    let canSave: Bool
    let onToggle: (String) -> Void
    let onBack: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SectionLabel(titleKey: "schedule.book.service")

            BookServiceChips(chips: chips, onToggle: onToggle)

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: onBack)

                Spacer()

                CapsuleButton(
                    titleKey: "schedule.actions.save",
                    role: .primary,
                    isEnabled: canSave,
                    action: onSave
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    BookingServiceEditor(
        chips: SchedulePreviewData.serviceChips,
        canSave: true,
        onToggle: { _ in },
        onBack: {},
        onSave: {}
    )
    .padding()
    .background(Color.card)
}
#endif
