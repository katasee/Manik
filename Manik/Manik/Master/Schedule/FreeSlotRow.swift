import SwiftUI

struct FreeSlotRow: View {
    let item: SlotItem

    var body: some View {
        ZStack {
            time
            freeLabel
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.rowHorizontalPadding)
        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.rowHeight)
        .overlay {
            RoundedRectangle(cornerRadius: ScheduleMetrics.Size.rowCornerRadius)
                .strokeBorder(
                    Color.stroke,
                    style: StrokeStyle(
                        lineWidth: ScheduleMetrics.Size.rowBorderWidth,
                        dash: ScheduleMetrics.Size.rowDash
                    )
                )
        }
        .opacity(item.isPast ? ScheduleMetrics.Size.pastOpacity : 1)
        .background(Color.background, in: .rect(cornerRadius: ScheduleMetrics.Size.rowCornerRadius))
        .accessibilityElement(children: .combine)
    }

    private var time: some View {
        Text(verbatim: item.timeText)
            .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowTime))
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var freeLabel: some View {
        Text("schedule.slot.free")
            .font(.elmsSans(.medium, ScheduleMetrics.Size.rowLabel))
            .textCase(.uppercase)
            .tracking(ScheduleMetrics.Size.rowLabelTracking)
            .foregroundStyle(Color.textSecondary)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
        ForEach(SchedulePreviewData.items) { item in
            FreeSlotRow(item: item)
        }
    }
    .padding()
    .background(Color.background)
}
#endif
