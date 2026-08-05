import SwiftUI

struct TimelineFreeSlots: View {
    let freeHours: Set<Int>
    let geometry: TimelineGeometry
    let onTapHour: (Int) -> Void

    var body: some View {
        ForEach(SalonHours.working.filter(freeHours.contains), id: \.self) { hour in
            DashedSlot(title: "schedule.slot.addFreeTime") {
                onTapHour(hour)
            }
            .padding(.leading, ScheduleMetrics.Spacing.contentLeadingPadding)
            .padding(.trailing, ScheduleMetrics.Spacing.timelineHorizontalPadding)
            .frame(height: geometry.hourHeight)
            .offset(y: geometry.offset(forHour: hour))
        }
    }
}

#if DEBUG
#Preview {
    TimelineFreeSlots(
        freeHours: Set(SalonHours.working),
        geometry: TimelineGeometry(
            hourHeight: ScheduleMetrics.Size.hourHeight,
            firstHour: SalonHours.working.lowerBound
        ),
        onTapHour: { _ in }
    )
    .background(Color.background)
}
#endif
