import SwiftUI

struct ScheduleView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                title
                date
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)

            WeekDayStrip(selectedDate: $selectedDate)
                .padding(.vertical, 12)

            Color.surface
                .frame(height: 1)

            HourlyTimelineView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
    
    private var title: some View {
        Text("schedule.title")
            .font(.elmsSans(.bold, 28))
            .foregroundStyle(Color.ink)
    }
    
    private var date: some View {
        Text(DateFormat.monthYear.string(from: selectedDate).capitalized)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.textSecondary)
    }
}

#Preview {
    ScheduleView()
}
