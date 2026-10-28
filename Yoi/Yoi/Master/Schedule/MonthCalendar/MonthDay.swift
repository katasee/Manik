struct MonthDay: Identifiable {
    let id: String
    let numberText: String
    let isEnabled: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasSlots: Bool
    let conflict: PlanConflict?
}
