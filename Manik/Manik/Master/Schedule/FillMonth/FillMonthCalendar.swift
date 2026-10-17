import SwiftUI

struct FillMonthCalendar: View {
    let viewModel: FillMonthViewModel

    var body: some View {
        MonthCalendarGrid(
            weekdays: viewModel.weekdays,
            leadingBlanks: viewModel.leadingBlanks,
            days: viewModel.days,
            onDay: viewModel.toggleDay
        ) { weekday in
            Button {
                toggleWeekday(weekday)
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
    }

    private func toggleWeekday(_ weekday: MonthWeekday) {
        viewModel.toggleWeekday(weekday.id)
    }
}

#if DEBUG
#Preview {
    FillMonthCalendar(viewModel: SchedulePreviewData.fillMonth)
        .padding()
        .background(Color.background)
}
#endif
