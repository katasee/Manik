import SwiftUI

struct ScheduleSlotRow: View {
    let item: SlotItem
    let onBook: () -> Void

    var body: some View {
        if let booking = item.booking {
            BookedSlotRow(item: item, booking: booking)
        } else {
            Button(action: onBook) {
                FreeSlotRow(item: item)
                    .contentShape(.rect(cornerRadius: ScheduleMetrics.Size.rowCornerRadius))
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("schedule.book.hint"))
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
        ForEach(SchedulePreviewData.items) { item in
            ScheduleSlotRow(item: item, onBook: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
