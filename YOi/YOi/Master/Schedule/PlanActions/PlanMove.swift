import Foundation

struct PlanMove {
    let days: [Date]
    let markedDays: Set<String>

    var day: Date
    var times: PlanTimes

    private let plan: PlanEvent
    private let now: Date

    init(plan: PlanEvent, plannedDays: Set<String>, now: Date) {
        let range = RescheduleDays(dateId: plan.date, now: now)

        days = range.days
        markedDays = plannedDays
        day = range.initialDay
        times = PlanTimes(startTime: plan.startTime, endTime: plan.endTime)
        self.plan = plan
        self.now = now
    }

    var movedPlan: PlanEvent? {
        guard times.isValid else { return nil }

        var moved = plan
        moved.date = DateFormat.date.string(from: day)
        moved.startTime = times.startTime
        moved.endTime = times.endTime

        let hasMoved = (moved.date, moved.startTime, moved.endTime) != (plan.date, plan.startTime, plan.endTime)

        guard hasMoved, moved.isPast(now: now) == false else { return nil }

        return moved
    }
}
