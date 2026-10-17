import SwiftUI

struct JumpToDateCalendar: View {
    let viewModel: JumpToDateViewModel
    let onPick: (String) -> Void

    var body: some View {
        MonthCalendarGrid(
            weekdays: viewModel.weekdays,
            leadingBlanks: viewModel.leadingBlanks,
            days: viewModel.days,
            onDay: onPick
        ) { weekday in
            Text(verbatim: weekday.letter)
                .font(.elmsSans(.semiBold, ScheduleMetrics.Size.weekdayLetter))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.dayCellHeight)
                .accessibilityHidden(true)
        }
    }
}

#if DEBUG
#Preview {
    JumpToDateCalendar(viewModel: SchedulePreviewData.jumpToDate, onPick: { _ in })
        .padding()
        .background(Color.background)
}
#endif
