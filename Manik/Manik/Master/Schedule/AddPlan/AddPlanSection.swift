import SwiftUI

struct AddPlanSection: View {
    @Bindable var viewModel: AddPlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            MonthDayPicker(selection: $viewModel.days)

            SectionLabel(titleKey: "schedule.plan.template")

            if viewModel.hasTemplates {
                BookServiceChips(chips: viewModel.templateChips, onToggle: viewModel.selectTemplate)
            } else {
                Text("schedule.plan.noTemplates")
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.planHint))
                    .foregroundStyle(Color.textSecondary)
            }

            SectionLabel(titleKey: "schedule.plan.time")

            PlanTimeFields(viewModel: viewModel)
        }
    }
}

#if DEBUG
#Preview {
    AddPlanSection(viewModel: SchedulePreviewData.addPlan)
        .padding()
        .background(Color.card)
}
#endif
