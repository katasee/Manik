import SwiftUI

struct PlanTimeFields: View {
    @Binding var times: PlanTimes

    var body: some View {
        VStack(spacing: ScheduleMetrics.Spacing.timeFieldSpacing) {
            HStack(spacing: ScheduleMetrics.Spacing.timeFieldSpacing) {
                field(
                    .start,
                    captionKey: "schedule.plan.start",
                    value: times.startText
                )

                field(
                    .end,
                    captionKey: "schedule.plan.end",
                    value: times.endText
                )
            }

            if times.editing == .start {
                TimeWheel(
                    time: $times.start,
                    hours: WorkHours.customHours,
                    minuteStep: WorkHours.minuteStep
                )
            } else {
                TimeWheel(
                    time: $times.end,
                    hours: WorkHours.customHours,
                    minuteStep: WorkHours.minuteStep
                )
            }
        }
    }

    private func field(
        _ field: PlanTimeField,
        captionKey: LocalizedStringKey,
        value: String
    ) -> some View {
        let isEditing = times.editing == field
        let shape = RoundedRectangle(cornerRadius: ScheduleMetrics.Size.timeFieldCornerRadius)

        return Button {
            edit(field)
        } label: {
            VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.timeFieldLineSpacing) {
                Text(captionKey)
                    .font(.elmsSans(.medium, ScheduleMetrics.Size.timeFieldCaption))
                    .foregroundStyle(isEditing ? Color.onPrimary : Color.textSecondary)

                Text(verbatim: value)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.timeFieldValue))
                    .foregroundStyle(isEditing ? Color.onPrimary : Color.ink)
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.rowHorizontalPadding)
            .frame(
                maxWidth: .infinity,
                minHeight: ScheduleMetrics.Size.timeFieldHeight,
                alignment: .leading
            )
            .selectableSurface(isSelected: isEditing, in: shape)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isEditing ? .isSelected : [])
    }

    private func edit(_ field: PlanTimeField) {
        times.editing = field
    }
}

#if DEBUG
#Preview {
    @Previewable @State var times = SchedulePreviewData.addPlan.times

    PlanTimeFields(times: $times)
        .padding()
        .background(Color.card)
}
#endif
