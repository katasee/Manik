import SwiftUI

enum BookingActionRole {
    case regular
    case destructive
}

struct BookingActionLabel: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    var role = BookingActionRole.regular
    var isChecked = false

    var body: some View {
        HStack(spacing: ScheduleMetrics.Spacing.actionContentSpacing) {
            if role == .destructive {
                Image(systemName: systemImage)
                    .font(.elmsSans(.medium, ScheduleMetrics.Size.actionIcon))
                    .foregroundStyle(Color.destructive)
                    .frame(width: ScheduleMetrics.Size.actionIconColumn)
                    .accessibilityHidden(true)
            } else {
                IconBadge(systemName: systemImage)
            }

            Text(titleKey)
                .font(.elmsSans(.semiBold, ScheduleMetrics.Size.actionTitle))
                .foregroundStyle(role == .destructive ? Color.destructive : Color.ink)

            Spacer(minLength: 0)

            if isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.elmsSans(.medium, ScheduleMetrics.Size.actionIcon))
                    .foregroundStyle(Color.freeSlot)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.actionRowPadding)
        .frame(minHeight: ScheduleMetrics.Size.actionRowHeight)
        .cardSurface(padding: 0, cornerRadius: ScheduleMetrics.Size.actionRowCornerRadius)
        .contentShape(.rect(cornerRadius: ScheduleMetrics.Size.actionRowCornerRadius))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
        BookingActionLabel(titleKey: "schedule.actions.write", systemImage: "bubble.left")
        BookingActionLabel(
            titleKey: "clients.contact.sms",
            systemImage: "message",
            isChecked: true
        )
        BookingActionLabel(
            titleKey: "schedule.actions.cancelBooking",
            systemImage: "xmark.circle",
            role: .destructive
        )
    }
    .padding()
    .background(Color.card)
}
#endif
