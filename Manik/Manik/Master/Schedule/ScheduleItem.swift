enum ScheduleItem: Identifiable {
    case slot(SlotItem)
    case plan(PlanItem)

    var id: String {
        switch self {
        case .slot(let item): item.id
        case .plan(let item): item.id
        }
    }
}
