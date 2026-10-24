import SwiftUI

struct SchedulePlanRow: View {
    let item: PlanItem

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: item.timeText)
                .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowTime))
                .foregroundStyle(Color.wine)
                .frame(width: ScheduleMetrics.Size.rowTimeWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.rowLineSpacing) {
                Text(verbatim: item.title)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowName))
                    .foregroundStyle(Color.wine)

                Text("schedule.plan.until \(item.endText)")
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.rowService))
                    .foregroundStyle(Color.wine)
            }
            .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.rowHorizontalPadding)
        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.bookedRowHeight)
        .cardSurface(
            fill: .wineSoft,
            padding: 0,
            cornerRadius: ScheduleMetrics.Size.rowCornerRadius
        )
        .opacity(item.isPast ? ScheduleMetrics.Size.pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
        ForEach(SchedulePreviewData.planItems) { item in
            SchedulePlanRow(item: item)
        }
    }
    .padding()
    .background(Color.background)
}
#endif
