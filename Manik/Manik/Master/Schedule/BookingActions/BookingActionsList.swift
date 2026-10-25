import SwiftUI

struct BookingActionsList: View {
    let contacts: [ClientContact]
    let canChangeService: Bool
    let canOpenCard: Bool
    let onChangeService: () -> Void
    let onReschedule: () -> Void
    let onOpenCard: () -> Void
    let onCancelBooking: () -> Void

    var body: some View {
        VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
            if contacts.isEmpty == false {
                ClientContactMenu(contacts: contacts) {
                    BookingActionLabel(titleKey: "schedule.actions.write", systemImage: "bubble.left")
                }
            }

            if canChangeService {
                ActionRowButton(
                    titleKey: "schedule.actions.changeService",
                    systemImage: "list.bullet.rectangle",
                    action: onChangeService
                )
            }

            ActionRowButton(
                titleKey: "schedule.actions.reschedule",
                systemImage: "arrow.left.arrow.right",
                action: onReschedule
            )

            if canOpenCard {
                ActionRowButton(
                    titleKey: "schedule.actions.clientCard",
                    systemImage: "person.crop.circle",
                    action: onOpenCard
                )
            }

            ActionRowButton(
                titleKey: "schedule.actions.cancelBooking",
                systemImage: "xmark.circle",
                role: .destructive,
                action: onCancelBooking
            )
        }
    }
}

#if DEBUG
#Preview {
    BookingActionsList(
        contacts: SchedulePreviewData.bookingActions.contacts,
        canChangeService: true,
        canOpenCard: true,
        onChangeService: {},
        onReschedule: {},
        onOpenCard: {},
        onCancelBooking: {}
    )
    .padding()
    .background(Color.card)
}
#endif
