import SwiftUI

struct ScheduleMonthButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ScheduleMetrics.Spacing.monthChevronSpacing) {
                Text(verbatim: title)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.monthTitle))
                    .foregroundStyle(Color.ink)

                Image(systemName: "chevron.down")
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.monthChevron))
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.monthRowHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("schedule.jump.hint"))
    }
}

#if DEBUG
#Preview {
    ScheduleMonthButton(title: "Жовтень 2026", action: {})
        .background(Color.background)
}
#endif
