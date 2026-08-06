import SwiftUI

struct TimelineHourGrid: View {
    let geometry: TimelineGeometry

    var body: some View {
        VStack(spacing: 0) {
            ForEach(SalonHours.working, id: \.self) { hour in
                Text(DateFormat.hourLabel(for: hour))
                    .font(.elmsSans(.bold, 16))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: geometry.hourHeight, alignment: .top)
            }
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
        .offset(y: -ScheduleMetrics.Size.hourLabelCentering)
    }
}

#if DEBUG
#Preview {
    TimelineHourGrid(
        geometry: TimelineGeometry(
            hourHeight: ScheduleMetrics.Size.hourHeight,
            firstHour: SalonHours.working.lowerBound
        )
    )
    .background(Color.background)
}
#endif
