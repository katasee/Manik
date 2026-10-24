import Foundation

enum ScheduleDayItems {
    private enum Order: Int {
        case slot
        case plan
    }

    static func make(
        day: String,
        slots: [Slot],
        plans: [PlanEvent],
        clientName: (String) -> String,
        now: Date
    ) -> [ScheduleItem] {
        let slotRows = slots
            .filter { $0.date == day }
            .map { slot in
                (
                    key: (slot.time, Order.slot.rawValue, slot.id ?? ""),
                    item: ScheduleItem.slot(
                        SlotItem(
                            slot: slot,
                            clientName: slot.clientId.map(clientName) ?? "",
                            now: now
                        )
                    )
                )
            }

        let planRows = plans
            .filter { $0.date == day }
            .map { plan in
                (
                    key: (plan.startTime, Order.plan.rawValue, plan.id ?? ""),
                    item: ScheduleItem.plan(PlanItem(plan: plan, now: now))
                )
            }

        return (slotRows + planRows)
            .sorted { $0.key < $1.key }
            .map(\.item)
    }
}
