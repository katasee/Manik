import SwiftUI

struct HourlyTimelineView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.rowSpacing) {
                ForEach(ScheduleMetrics.workingHours, id: \.self) { hour in
                    Text(String(format: "%02d:00", hour))
                        .font(.elmsSans(.bold, 16))
                        .foregroundStyle(Color.textSecondary)

                    DashedSlot(title: "schedule.slot.addFreeTime", action: {})
                        .padding(.leading, ScheduleMetrics.Size.hourLabelWidth)
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
            .padding(.vertical, ScheduleMetrics.Spacing.rowSpacing)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    HourlyTimelineView()
        .background(Color.background)
}
