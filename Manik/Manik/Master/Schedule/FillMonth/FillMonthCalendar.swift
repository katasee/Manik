import SwiftUI

struct FillMonthCalendar: View {
    let viewModel: FillMonthViewModel

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: ScheduleMetrics.Spacing.calendarColumnSpacing),
        count: 7
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.calendarRowSpacing) {
            ForEach(viewModel.weekdays) { weekday in
                Button {
                    viewModel.toggleWeekday(weekday.id)
                } label: {
                    Text(verbatim: weekday.letter)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.weekdayLetter))
                        .foregroundStyle(weekday.isEnabled ? Color.textSecondary : Color.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.dayCellHeight)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(weekday.isEnabled == false)
                .accessibilityLabel(Text("schedule.fill.weekday \(weekday.name)"))
            }

            ForEach(blankIds, id: \.self) { _ in
                Color.clear
            }

            ForEach(viewModel.days) { day in
                MonthDayCell(day: day) {
                    viewModel.toggleDay(day.id)
                }
            }
        }
    }

    private var blankIds: [String] {
        (0..<viewModel.leadingBlanks).map { "blank-\($0)" }
    }
}

#if DEBUG
#Preview {
    FillMonthCalendar(viewModel: SchedulePreviewData.fillMonth)
        .padding()
        .background(Color.background)
}
#endif
