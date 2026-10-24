import SwiftUI

struct PlanTimeFields: View {
    @Bindable var viewModel: AddPlanViewModel

    var body: some View {
        VStack(spacing: ScheduleMetrics.Spacing.timeFieldSpacing) {
            HStack(spacing: ScheduleMetrics.Spacing.timeFieldSpacing) {
                field(
                    .start,
                    captionKey: "schedule.plan.start",
                    value: viewModel.startText
                )

                field(
                    .end,
                    captionKey: "schedule.plan.end",
                    value: viewModel.endText
                )
            }

            if viewModel.editing == .start {
                TimeWheel(time: $viewModel.start, hours: WorkHours.customHours)
            } else {
                TimeWheel(time: $viewModel.end, hours: WorkHours.customHours)
            }
        }
    }

    private func field(
        _ field: PlanTimeField,
        captionKey: LocalizedStringKey,
        value: String
    ) -> some View {
        let isEditing = viewModel.editing == field
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
            .background {
                if isEditing {
                    shape
                        .fill(Color.primaryFill)
                        .brandShadow()
                } else {
                    Color.clear
                        .raisedSurface(shape)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isEditing ? .isSelected : [])
    }

    private func edit(_ field: PlanTimeField) {
        viewModel.editing = field
    }
}

#if DEBUG
#Preview {
    PlanTimeFields(viewModel: SchedulePreviewData.addPlan)
        .padding()
        .background(Color.card)
}
#endif
