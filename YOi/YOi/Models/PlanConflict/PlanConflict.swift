enum PlanConflict: Comparable {
    case near
    case overlap

    init?(windowMinute: Int, planStart: Int, planEnd: Int) {
        if planStart <= windowMinute, windowMinute < planEnd {
            self = .overlap
        } else if (1...WorkHours.planLeadMinutes).contains(planStart - windowMinute) {
            self = .near
        } else {
            return nil
        }
    }
}
