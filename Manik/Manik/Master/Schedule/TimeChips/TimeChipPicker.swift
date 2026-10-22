import SwiftUI

struct TimeChipPicker: View {
    let times: [TimeChipItem]
    let spacing: CGFloat
    let onToggle: (String) -> Void
    let onRemoveCustom: (String) -> Void
    let onAddCustom: (ClockTime) -> Void

    @State private var isPickingCustomTime = false
    @State private var customTime = WorkHours.defaultCustomTime

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: ScheduleMetrics.Spacing.chipSpacing),
        count: 4
    )

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if times.isEmpty == false {
                LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.chipSpacing) {
                    ForEach(times) { time in
                        TimeChip(time: time) {
                            tap(time)
                        }
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
                onAdd: { onAddCustom(customTime) },
                onDismiss: closeCustomTime
            )
            .presentationBackground(.clear)
        }
    }

    private func tap(_ time: TimeChipItem) {
        if time.isCustom {
            onRemoveCustom(time.id)
        } else {
            onToggle(time.id)
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
}

#if DEBUG
#Preview {
    TimeChipPicker(
        times: SchedulePreviewData.fillMonth.times,
        spacing: ScheduleMetrics.Spacing.hoursSpacing,
        onToggle: { _ in },
        onRemoveCustom: { _ in },
        onAddCustom: { _ in }
    )
    .padding()
    .background(Color.background)
}
#endif
