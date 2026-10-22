import SwiftUI

struct FillMonthHours: View {
    let viewModel: FillMonthViewModel

    @State private var isPickingCustomTime = false
    @State private var customTime = ClockTime(minutesOfDay: 9 * 60 + 30)

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: ScheduleMetrics.Spacing.chipSpacing),
        count: 4
    )

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.hoursSpacing) {
            SectionLabel(titleKey: "schedule.fill.hours")

            LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.chipSpacing) {
                ForEach(viewModel.times) { time in
                    TimeChip(time: time) {
                        tap(time)
                    }
                }
            }

            CapsuleButton(
                titleKey: "schedule.fill.customTime",
                role: .secondary,
                systemImage: "plus",
                fillsWidth: true,
                action: openCustomTime
            )
        }
        .fullScreenCover(isPresented: $isPickingCustomTime) {
            CustomTimePopup(
                time: $customTime,
                onAdd: addCustomTime,
                onDismiss: closeCustomTime
            )
            .presentationBackground(.clear)
        }
    }

    private func tap(_ time: TimeChipItem) {
        if time.isCustom {
            viewModel.removeCustomTime(time.id)
        } else {
            viewModel.toggleTime(time.id)
        }
    }

    private func openCustomTime() {
        withoutPresentationAnimation {
            isPickingCustomTime = true
        }
    }

    private func closeCustomTime() {
        withoutPresentationAnimation {
            isPickingCustomTime = false
        }
    }

    private func addCustomTime() {
        viewModel.addCustomTime(customTime)
    }
}

#if DEBUG
#Preview {
    FillMonthHours(viewModel: SchedulePreviewData.fillMonth)
        .padding()
        .background(Color.background)
}
#endif
