import SwiftUI

struct ScheduleView: View {
    @State private var selectedDate = Date.now

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(titleKey: "schedule.title", subtitle: monthTitle) {
                RoundIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "schedule.action.addSlots",
                    action: {}
                )
            }

            WeekDayStrip(selectedDate: $selectedDate)
                .padding(.vertical, ScheduleMetrics.Spacing.stripVerticalPadding)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }

    private var monthTitle: String {
        DateFormat.monthYear.string(from: selectedDate).capitalized
    }
}

#Preview {
    ScheduleView()
}
