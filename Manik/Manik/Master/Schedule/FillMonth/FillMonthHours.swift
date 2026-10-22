import SwiftUI

struct FillMonthHours: View {
    let viewModel: FillMonthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.hoursSpacing) {
            SectionLabel(titleKey: "schedule.fill.hours")

            TimeChipPicker(
                times: viewModel.times,
                spacing: ScheduleMetrics.Spacing.hoursSpacing,
                onToggle: viewModel.toggleTime,
                onRemoveCustom: viewModel.removeCustomTime,
                onAddCustom: viewModel.addCustomTime
            )
        }
    }
}

#if DEBUG
#Preview {
    FillMonthHours(viewModel: SchedulePreviewData.fillMonth)
        .padding()
        .background(Color.background)
}
#endif
