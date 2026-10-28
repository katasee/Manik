import Foundation

private struct TimedPlan {
    let plan: PlanEvent
    let start: Int
    let end: Int

    init?(_ plan: PlanEvent) {
        guard
            let start = DateFormat.minutesOfDay(plan.startTime),
            let end = DateFormat.minutesOfDay(plan.endTime)
        else { return nil }

        self.plan = plan
        self.start = start
        self.end = end
    }
}

struct WindowConflict {
    let window: Slot
    let plan: PlanEvent
    let level: PlanConflict

    static func find(windows: [Slot], plans: [PlanEvent], now: Date) -> [WindowConflict] {
        let plansByDate = Dictionary(grouping: plans.compactMap(TimedPlan.init), by: \.plan.date)

        return windows
            .sorted(by: Slot.chronologically)
            .flatMap { window in
                guard
                    let dayPlans = plansByDate[window.date],
                    window.isPast(now: now) == false,
                    let windowMinute = DateFormat.minutesOfDay(window.time)
                else { return [WindowConflict]() }

                return dayPlans
                    .sorted { $0.plan.startTime < $1.plan.startTime }
                    .compactMap { timed in
                        PlanConflict(
                            windowMinute: windowMinute,
                            planStart: timed.start,
                            planEnd: timed.end
                        )
                        .map { WindowConflict(window: window, plan: timed.plan, level: $0) }
                    }
            }
    }

    static func worstLevels(
        _ conflicts: [WindowConflict],
        by key: (WindowConflict) -> String
    ) -> [String: PlanConflict] {
        Dictionary(conflicts.map { (key($0), $0.level) }, uniquingKeysWith: max)
    }
}
