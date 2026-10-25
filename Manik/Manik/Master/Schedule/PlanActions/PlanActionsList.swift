import SwiftUI

struct PlanActionsList: View {
    let canChangeTemplate: Bool
    let onChangeTemplate: () -> Void
    let onReschedule: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
            if canChangeTemplate {
                ActionRowButton(
                    titleKey: "schedule.plan.actions.change",
                    systemImage: "arrow.triangle.2.circlepath",
                    action: onChangeTemplate
                )
            }

            ActionRowButton(
                titleKey: "schedule.actions.reschedule",
                systemImage: "arrow.left.arrow.right",
                action: onReschedule
            )

            ActionRowButton(
                titleKey: "schedule.plan.actions.delete",
                systemImage: "trash",
                role: .destructive,
                action: onDelete
            )
        }
    }
}

#if DEBUG
#Preview {
    PlanActionsList(
        canChangeTemplate: SchedulePreviewData.planActions.canChangeTemplate,
        onChangeTemplate: {},
        onReschedule: {},
        onDelete: {}
    )
    .padding()
    .background(Color.card)
}
#endif
