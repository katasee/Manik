import Foundation

struct PlanItem: Identifiable {
    let id: String
    let timeText: String
    let title: String
    let endText: String
    let isPast: Bool

    init(plan: PlanEvent, now: Date) {
        id = plan.id ?? ""
        timeText = DateFormat.displayTime(plan.startTime)
        title = "\(plan.emoji) \(plan.name)"
        endText = DateFormat.displayTime(plan.endTime)
        isPast = plan.isPast(now: now)
    }
}
