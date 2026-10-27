import SwiftUI

struct MonthDayPicker: View {
    @Binding var selection: MonthDaySelection
    let conflicts: [String: PlanConflict]

    var body: some View {
        VStack(spacing: PopupContainerLayout.rowSpacing) {
            MonthHeader(
                title: selection.monthTitle,
                canGoBack: selection.canGoBack,
                canGoForward: true,
                onPrevious: showPreviousMonth,
                onNext: showNextMonth
            )

            MonthCalendarGrid(
                weekdays: selection.weekdays,
                leadingBlanks: selection.leadingBlanks,
                days: selection.days(conflicts: conflicts),
                onDay: toggleDay
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
    }

    private func showPreviousMonth() {
        selection.showPrevious()
    }

    private func showNextMonth() {
        selection.showNext()
    }

    private func toggleDay(_ id: String) {
        selection.toggleDay(id)
    }

    private func toggleWeekday(_ weekday: MonthWeekday) {
        selection.toggleWeekday(weekday.id)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var viewModel = SchedulePreviewData.fillMonth

    MonthDayPicker(selection: $viewModel.days, conflicts: viewModel.dayConflicts)
        .padding()
        .background(Color.background)
}
#endif
