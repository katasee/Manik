import SwiftUI

struct MonthCalendarGrid<Weekday: View>: View {
    let weekdays: [MonthWeekday]
    let leadingBlanks: Int
    let days: [MonthDay]
    let onDay: (String) -> Void
    @ViewBuilder let weekday: (MonthWeekday) -> Weekday

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: ScheduleMetrics.Spacing.calendarColumnSpacing),
        count: 7
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.calendarRowSpacing) {
            ForEach(weekdays, content: weekday)

            ForEach(blankIds, id: \.self) { _ in
                Color.clear
            }

            ForEach(days) { day in
                MonthDayCell(day: day) {
                    onDay(day.id)
                }
            }
        }
    }

    private var blankIds: [String] {
        (0..<leadingBlanks).map { "blank-\($0)" }
    }
}
