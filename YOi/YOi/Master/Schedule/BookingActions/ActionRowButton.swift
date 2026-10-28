import SwiftUI

struct ActionRowButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    var role = BookingActionRole.regular
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BookingActionLabel(
                titleKey: titleKey,
                systemImage: systemImage,
                role: role
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
        ActionRowButton(
            titleKey: "schedule.actions.reschedule",
            systemImage: "arrow.left.arrow.right",
            action: {}
        )
        ActionRowButton(
            titleKey: "schedule.actions.cancelBooking",
            systemImage: "xmark.circle",
            role: .destructive,
            action: {}
        )
    }
    .padding()
    .background(Color.card)
}
#endif
