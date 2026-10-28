import SwiftUI

struct ScheduleSlotRow: View {
    let item: SlotItem
    let onBook: () -> Void
    let onOpenActions: () -> Void

    var body: some View {
        if let booking = item.booking {
            BookedSlotRow(item: item, booking: booking)
                .contentShape(.rect(cornerRadius: ScheduleMetrics.Size.rowCornerRadius))
                .onTapGesture(perform: onOpenActions)
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("schedule.actions.hint"))
        } else {
            FreeSlotRow(item: item)
                .contentShape(.rect(cornerRadius: ScheduleMetrics.Size.rowCornerRadius))
                .onTapGesture(perform: onBook)
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("schedule.book.hint"))
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
        ForEach(SchedulePreviewData.items) { item in
            ScheduleSlotRow(item: item, onBook: {}, onOpenActions: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
